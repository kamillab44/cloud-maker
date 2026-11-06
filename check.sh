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