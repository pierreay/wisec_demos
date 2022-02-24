#!/usr/bin/env python3

from argparse import ArgumentParser

from asynciojobs import Scheduler, Sequence

from apssh import SshNode, SshJob, LocalNode
from apssh import Run, RunString, RunScript
from apssh import Push, Pull

from r2lab import r2lab_hostname, r2lab_data

##########
verbose_ssh = False
aux_script = "./experiment.sh"
gateway_hostname  = 'faraday.inria.fr'
gateway_username  = 'eurecoms3_a'

wireless_driver = "ath9k"
interface = "atheros"

parser = ArgumentParser()
parser.add_argument("-s", "--slice", default=gateway_username,
                    help="specify an alternate slicename, default={}"
                         .format(gateway_username))
parser.add_argument("-l", "--load", default=False, action='store_true',
                    help="load the ubuntu image on nodes before starting")
parser.add_argument("-d", "--debug", default=False, action='store_true',
                    help="also collect with tshark for debugging")
parser.add_argument("-v", "--verbose-ssh", default=False, action='store_true',
                    help="run ssh in verbose mode")
parser.add_argument("-a", "--node-a", default="fit36",
                    help="gps spoofer")
parser.add_argument("-b", "--node-b", default="fit24",
                    help="wifi hotspot")
parser.add_argument("-e", "--node-e", default="macphone1",
                    help="mobile phone Nexus 5")

args = parser.parse_args()

gateway_username = args.slice
verbose_ssh = args.verbose_ssh

##########
faraday = SshNode(hostname = gateway_hostname, username = gateway_username,
                  verbose = verbose_ssh)

# r2lab_hostname will accept inputs like '1', '01', or 'fit01'
hostnamea = r2lab_hostname(args.node_a)
hostnameb = r2lab_hostname(args.node_b)
hostnamee = r2lab_hostname(args.node_e)

nodea = SshNode(gateway = faraday, hostname = hostnamea, username = "root",
                verbose = verbose_ssh)
nodeb = SshNode(gateway = faraday, hostname = hostnameb, username = "root",
                verbose = verbose_ssh)
nodee = SshNode(gateway = faraday, hostname = hostnamee, username = "root",
                verbose = verbose_ssh)


def check_lease(experiment_scheduler, sshnode):

    """
    re-usable function that acts a bit like a python
    decorator on schedulers.

    Given an experiment described as a scheduler, this function
    returns a higher-level scheduler that first checks for the
    lease, and then proceeds with the experiment.
    """

    check_lease_job = SshJob(
        # checking the lease is done on the gateway
        node = faraday,
        # this means that a failure in any of the commands
        # will cause the scheduler to bail out immediately
        critical = True,
        command = Run("rhubarbe leases --check"),
    )

    return Scheduler(
        Sequence(
            check_lease_job,
            # here we create a nested scheduler
            # by inserting the experiment_scheduler
            # as a regular job in the main scheduler
            experiment_scheduler,
        )
    )


##########
# create an orchestration scheduler
scheduler = Scheduler()


# the job to wait before proceeding
ready_requirement = None
# has the user requested to load images ?
# if so, we just need to wait for 2 jobs to complete instead of 1
if args.load:
    ready_requirement = [
        Sequence(
            SshJob(
                node = faraday,
                commands = [
                    Run('rhubarbe on', hostnamea, hostnameb),
                    Run('rhubarbe load -i ubuntu', hostnamea, hostnameb),
                    Run('rhubarbe usrpon', hostnamea),
                    Run('rhubarbe wait', hostnamea, hostnameb),
                    ],
                scheduler = scheduler,
            ),
            SshJob(
                node = nodea,
                commands = [
                    Run("apt install -y gnuradio"),
                    RunScript(
                        aux_script,
                        "usrp-2-set",
                    ),
                    RunScript(
                        aux_script,
                        "spoofer-install"
                    )
                ],
                scheduler = scheduler,
            ),
            SshJob(
                node = nodeb,
                commands = [
                    Run("apt-get -y install network-manager"),
                    Run("service network-manager start"),
                    RunScript(
                        aux_script,
                        "hotspot-create"
                    )
                ],
                scheduler = scheduler,
            ),
        ),
        SshJob(
            node = faraday,
            commands = [
                Run('rhubarbe bye -a', '~'+hostnamea, '~'+hostnameb,
                    '~'+hostnamee)
            ],
            scheduler = scheduler,
        ),
    ]
    # ok = scheduler.orchestrate()
    # ok or scheduler.debrief()
    # scheduler.export_as_dotfile("D4.dot")
    # exit(0 if ok else 1)

scheduler = check_lease(scheduler, faraday)

spoof = Sequence(
    SshJob(
        node = nodea,
        command = RunScript(
            aux_script,
            "spoof",
        ),
    ),
    required = ready_requirement,
    scheduler = scheduler,
)

# spoof = Sequence(
    # SshJob(
        # node = LocalNode(),
        # command = Run("vncviewer faraday-macphone1.inria.fr -UserName tester"),
    # ),
    # required = ready_requirement,
    # scheduler = scheduler,
# )

##########
# run the scheduler
ok = scheduler.orchestrate()
# give details if it failed
ok or scheduler.debrief()

# return something useful to your OS
exit(0 if ok else 1)
