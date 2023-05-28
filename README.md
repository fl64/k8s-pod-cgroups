# pod cgroup info

A tool to get cgroup parameters for containers of a given pod. Currently only works with containerd as CRI.

## How does it work?

A DaemonSet `cgroup-prober` is created in the cluster which has access to `containerd` socket and the `/proc` `/sys` directories on the host system. From these, the `get-cgroup-info.sh` script gets the necessary data for each container's cgroup.

## How to use?

```bash
./get-cgroup-info.sh <namespace> <podname>
```

Example:

```
 ./get-cgroup-info.sh test echo-lim-1500m-req-1500m
Prober pods:
  pod: cgroup-prober-4ds9x node: virtlab-pt-0
  pod: cgroup-prober-d9hxt node: virtlab-pt-2
  pod: cgroup-prober-k72bm node: virtlab-pt-1

Discover containers cgroups for pod: echo-lim-1500m-req-1500m in namespace: test on node: virtlab-pt-1 via pod: cgroup-prober-k72bm
  Container: echo-lim-1500m-req-1500m, containerd ID: 1e720299c0efea99b328913faa18dd705464b4155347b82ad99d3f58612b47bd
    Process PID: 1365361
      cgroup: cpuset path: /kubepods/pod7581e72b-89d0-4d4e-a455-cba2568c9d05/1e720299c0efea99b328913faa18dd705464b4155347b82ad99d3f58612b47bd
        cgroup.clone_children:0
        cpuset.cpu_exclusive:0
        cpuset.cpus:0,4-6,10-11
        cpuset.effective_cpus:0,4-6,10-11
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
        notify_on_release:0
      cgroup: cpu,cpuacct path: /kubepods/pod7581e72b-89d0-4d4e-a455-cba2568c9d05/1e720299c0efea99b328913faa18dd705464b4155347b82ad99d3f58612b47bd
        cgroup.clone_children:0
        cpu.cfs_burst_us:0
        cpu.cfs_period_us:100000
        cpu.cfs_quota_us:150000
        cpu.idle:0
        cpu.shares:1536
        cpu.stat:nr_periods 7
        cpu.stat:nr_throttled 0
        cpu.stat:throttled_time 0
        cpu.uclamp.max:max
        cpu.uclamp.min:0.00
        notify_on_release:0
```
