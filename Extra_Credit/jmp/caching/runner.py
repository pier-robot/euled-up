import time
import subprocess

def test_c():
    base_cmd = ["./caching"]
    args = ["", "A", "B", "C", "D"]
    print("\tdef","\t".join(args))
    for opt in ["-O0", "-O1", "-O2", "-O3"]:
        cmd = ["gcc", "-march=native", opt, "-o", "caching", "caching.c"]
        proc = subprocess.Popen(cmd, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
        stdout,stderr = proc.communicate()
        if proc.returncode:
            print("Something broke")
            print(stderr)
            break

        print(opt, end="\t")
        for arg in args:
            cmd = base_cmd[:]
            if arg:
                cmd.append(arg)
            start = time.perf_counter()
            proc = subprocess.Popen(cmd, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
            _,out = proc.communicate()
            delta = time.perf_counter() - start
            print("{0:.3f}".format(delta), end="\t")
        print()

def test_zig():
    base_cmd = ["./zig-cache/bin/caching"]
    args = ["", "A", "B", "C", "D"]
    print("\tdef","\t".join(args))
    for opt in ["", "-Drelease-safe", "-Drelease-small", "-Drelease-fast"]:
        cmd = ["zig", "build", "-Dtarget=native"]
        if opt:
            cmd.append(opt)
        proc = subprocess.Popen(cmd, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
        stdout,stderr = proc.communicate()
        if proc.returncode:
            print("Something broke")
            print(stderr)
            break

        print(opt, end="\t")
        for arg in args:
            cmd = base_cmd[:]
            if arg:
                cmd.append(arg)
            start = time.perf_counter()
            proc = subprocess.Popen(cmd, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
            _,out = proc.communicate()
            delta = time.perf_counter() - start
            print("{0:.3f}".format(delta), end="\t")
        print()

test_zig()

"""
        def     A       B       C       D
        44.106  53.816  53.116  54.538  49.805
-Drelease-safe  4.173   5.611   4.536   4.042   4.083
-Drelease-small 1.417   4.141   4.303   1.998   2.081
-Drelease-fast  1.128   2.136   1.283   1.120   1.088


        def     A       B       C       D
        41.498  52.666  53.624  48.372  50.752
-Drelease-safe  4.036   5.832   4.465   3.962   4.062
-Drelease-small 1.408   4.138   4.202   1.981   1.990
-Drelease-fast  1.151   2.134   1.267   1.104   1.085


        def     A       B       C       D
-O0     17.242  17.090  17.689  15.211  15.709
-O1     0.025   0.023   0.025   0.024   0.022
-O2     0.023   0.024   4.260   3.908   2.110
-O3     2.275   2.189   1.324   0.516   0.509
"""
