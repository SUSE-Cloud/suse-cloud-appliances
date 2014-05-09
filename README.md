# Automated Deployment of a Highly Available OpenStack Cloud

This repository contains the training materials used for
[the workshop session given on Thursday May 15 at the OpenStack summit in
Atlanta](http://openstacksummitmay2014atlanta.sched.org/event/d3db2188dfed4459f8fbd03f5b405b81).

## Contents

* the presentation
    *   You can [view this online](http://fghaas.github.io/openstacksummit2014-atlanta/).
        If you want to view it locally, after cloning this repository
        you will have to check out the
        [git submodules](http://git-scm.com/book/en/Git-Tools-Submodules)
        via the following commands in order to satisfy the presentation's
        external dependencies ([`reveal.js`](https://github.com/hakimel/reveal.js)
        and [`qrcodejs`](https://github.com/davidshimjs/qrcodejs)):

            git submodule init
            git submodule update
* [resources for building the KIWI appliances](kiwi/)
* [resources for building the Vagrant boxes](vagrant/) from the KIWI appliances

## Authors

*   [Florian Haas](http://openstacksummitmay2014atlanta.sched.org/speaker/fghaas),
    CEO and Principal Consultant at [Hastexo](http://hastexo.com)
*   [Adam Spiers](http://openstacksummitmay2014atlanta.sched.org/speaker/aspiers),
    Senior Software Engineer at [SUSE](http://suse.com/cloud)
