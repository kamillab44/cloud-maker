# Cloud Maker (Base Task + cloud-init + Check Script)

## 🛠 What Was Done

1. **Base Task (4 points):** Created and launched a Virtual Machine using QEMU/KVM strictly from the command line (no GUI). Hardware acceleration (KVM) is enabled.
2. **Feature 2 (cloud-init):** Configured the VM to automatically set up a hostname, create a `student` user with a password, and install `openssh-server` on the first boot using cloud-init (`user-data`).
3. **Feature 11 (Check Script):** Created a bash script (`check.sh`) that automatically launches the VM in the background, verifies it is running, and shuts it down.

---

## 📋 Prerequisites

* Linux host with QEMU/KVM installed.
* The files `test-vm.qcow2` (VM disk) and `seed.iso` (cloud-init config) must be in the same directory.

---

## 🚀 How to Run and Verify

### Option 1: Manual Launch

1. Start the VM using the following command:
   ```bash
   sudo qemu-system-x86_64 -enable-kvm -m 1024 -smp 2 \
     -drive file=test-vm.qcow2,format=qcow2 \
     -drive file=seed.iso,format=raw \
     -netdev user,id=net0,hostfwd=tcp::2222-:22 \
     -device virtio-net-pci,netdev=net0 \
     -nographic
   ```

2. You will see the login prompt:
   ```text
   test-vm login:
   ```

3. Log in with the credentials applied by cloud-init:
   * **Username:** `student`
   * **Password:** `12345`

4. Verify you are inside the VM. The prompt should look like:
   ```bash
   student@test-vm:~$
   ```

### Option 2: Automated Check (Script)

Run the script to automatically start, verify, and stop the VM:
```bash
chmod +x check.sh
./check.sh
```

**Expected output:**
```text
Starting VM...
Waiting 10 seconds for boot...
SUCCESS: VM is running correctly!
VM stopped.
```

---

## ⚙️ cloud-init Configuration (`user-data`)

The file `user-data` contains the following YAML configuration:

```yaml
#cloud-config
hostname: test-vm
users:
  - name: student
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
chpasswd:
  list: |
    student:12345
  expire: False
ssh_pwauth: True
packages:
  - openssh-server
```

---

## 📜 Check Script (`check.sh`)

The script uses `-display none -daemonize` to run QEMU in the background without blocking the terminal. It then checks if the process is alive using `pgrep` and terminates it using `pkill`.

```bash
#!/bin/bash

echo "Starting VM..."
sudo qemu-system-x86_64 -enable-kvm -m 1024 -smp 2 \
  -drive file=test-vm.qcow2,format=qcow2 \
  -drive file=seed.iso,format=raw \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -device virtio-net-pci,netdev=net0 \
  -display none -daemonize

echo "Waiting 10 seconds for boot..."
sleep 10

if pgrep -f "qemu-system-x86_64" > /dev/null; then
    echo "SUCCESS: VM is running correctly!"
    sudo pkill -f "qemu-system-x86_64"
    echo "VM stopped."
else
    echo "ERROR: VM failed to start."
    exit 1
fi
```
