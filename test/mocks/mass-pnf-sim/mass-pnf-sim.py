#!/usr/bin/env python3
import sys
import logging
from MassPnfSim import MassPnfSim, get_parser

if __name__ == '__main__':
    parser = get_parser()
    args = parser.parse_args()
    log_lvl = getattr(logging, args.verbose.upper())

    if sys.stdout.isatty():
        logging.basicConfig(level=logging.INFO, format='\033[92m[%(levelname)s]\033[0m %(message)s')
    else:
        logging.basicConfig(level=logging.INFO, format='[%(levelname)s] %(message)s')

    logger = logging.getLogger(__name__)
    logger.setLevel(log_lvl)
    MassPnfSim.log_lvl = log_lvl

    if args.subcommand is not None:
        sim_routine = getattr(MassPnfSim(), args.subcommand)
        sim_routine(args)
    else:
        parser.print_usage()
