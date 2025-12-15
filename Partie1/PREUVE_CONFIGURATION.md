# PREUVE: Problème de configuration sudo

## Commande qui échoue
```bash
sudo /usr/bin/usermod -l testuser24 user24
sudo: /usr/bin/usermod: command not found
$ which -a usermod
/usr/sbin/usermod
/sbin/usermod

$ ls -la /usr/bin/usermod 2>/dev/null || echo "Not in /usr/bin"
Not in /usr/bin

$ ls -la /usr/sbin/usermod
-rwxr-xr-x 1 root root 126424 Feb  6  2024 /usr/sbin/usermod


### **Step 2: Test What Actually WORKS**

```bash
# Test password change (this WORKS)
sudo /usr/bin/passwd user24 << 'EOF'
Pass024
Pass024
