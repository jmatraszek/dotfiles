## Encrypt accounts.txt
    gpg --output accounts.txt.gpg --symmetric accounts.txt

## Decrypt accounts.txt.gpg
    gpg --textmode --output - --decrypt accounts.txt.gpg
