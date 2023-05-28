# pod cgroup info

A tool to get cgroup parameters for containers of a given pod. Currently only works with containerd as CRI.

## How does it work?

A DaemonSet `cgroup-prober` is created in the cluster which has access to `containerd` socket and the `/proc` `/sys` directories on the host system. From these, the `get-cgroup-info.sh` script gets the necessary data for each container's cgroup.

## How to use?

```bash
./get-cgroup-info.sh -n <namespace> <podname>

# or

./get-cgroup-info.sh -n <namespace> -l <podlable=labelvalue>
```

Example:

```bash
/get-cgroup-info.sh -n vms -l "vm.kubevirt.io/name=vm-vm2" -f cpuset
Namespace: vms
Labels: vm.kubevirt.io/name=vm-vm2
Pod Name:
Cgroup name filter: cpuset
Prober pods:
  pod: cgroup-prober-4ds9x. node  virtlab-pt-0.
  pod: cgroup-prober-d9hxt. node  virtlab-pt-2.
  pod: cgroup-prober-k72bm. node  virtlab-pt-1.

Detecting cgroups for pod containers: virt-launcher-vm-vm2-c2n6x in namespace: vms on node: virtlab-pt-1 via pod: cgroup-prober-k72bm.
  Container: compute containerd ID: 2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a.
    Process PID: 1946340
    Process cgroupPath: /kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a
    - 13:memory:/kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a
    - 12:perf_event:/kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a
    - 11:blkio:/kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a
    - 10:cpuset:/kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a/housekeeping
    - 9:hugetlb:/kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a
    - 8:pids:/kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a
    - 7:net_cls,net_prio:/kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a
    - 6:devices:/kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a
    - 5:cpu,cpuacct:/kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a
    - 4:misc:/kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a
    - 3:rdma:/kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a
    - 2:freezer:/kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a
    - 1:name=systemd:/kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a
    - 0::/kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a
    Process CGroups:
      cgroup: memory path: /kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a.
      cgroup: perf_event path: /kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a.
      cgroup: blkio path: /kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a.
      cgroup: cpuset path: /kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a/housekeeping.
        cpuset.cpu_exclusive:0
        cpuset.cpus:2
        cpuset.effective_cpus:2
        cpuset.effective_mems:0
        cpuset.mem_exclusive:0
        cpuset.mem_hardwall:0
        cpuset.memory_migrate:0
        cpuset.memory_pressure:0
        cpuset.memory_spread_page:0
        cpuset.memory_spread_slab:0
        cpuset.mems:0
        cpuset.sched_load_balance:1
        cpuset.sched_relax_domain_level:-1
      cgroup: hugetlb path: /kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a.
      cgroup: pids path: /kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a.
      cgroup: net_clsnet_prio: path: /kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a.
      cgroup: devices path: /kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a.
      cgroup: cpucpuacct: path: /kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a.
      cgroup: misc path: /kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a.
      cgroup: rdma path: /kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a.
      cgroup: freezer path: /kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a.
      cgroup: name=systemd path: /kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a.
      cgroup:  path: /kubepods/pod8c52fb9d-0a0c-4e4b-bea2-8da0ed0870c5/2cf7b0992492cfc7b4c473e2d022758ee09be9dd3761b3ee2d87598eec9a045a.
```
