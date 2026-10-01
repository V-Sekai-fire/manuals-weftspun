# Enrolling the Windows desk on bao-8, and bao-8's PKI key that does not decrypt

On 2026-09-30 the Windows desk had no Bao identity: bao-8 refused its old `~/.magi` certificate
and its WSL bundle was gone. Its session sent the Mac desk a CSR; the operator approved the
enrollment to the Mac desk directly, after the Mac desk had declined it as a peer's request.

## The request

| Check | Result |
| --- | --- |
| CSR self-signature | `verify OK` |
| Subject | `CN=windows-156928.chibifire.com, O=chibifire` |
| Key | RSA 4096; public-key sha256 `858bb9ec…22d60dc0fa`, as the Windows session stated it |
| Requested extensions | key usage digitalSignature, keyEncipherment; extended key usage clientAuth; SAN `DNS:windows-156928.chibifire.com` |

## bao-8's `pki/` cannot sign

`pki/` lists `chibifire.com Intermediate CA v2` (issuer `c03d58b9-e462-262e-4714-01f24276abd6`)
with a `key_id`, the issuer that signed the Mac desk's own agent certificate. Signing through it
with the root token fails:

    bao write pki/issuer/c03d58b9-…/sign-verbatim csr=@windows-156928.csr ttl=8760h \
        key_usage=DigitalSignature,KeyEncipherment ext_key_usage=ClientAuth
    Code: 500. no decryption key available for term 83886080

The issuer's key entry was written under a keyring term bao-8 does not hold, so `pki/` issues
nothing on this node. RFD 2293 planned the `zone-fly` certificate through Bao's PKI; that waits
on this. Unchecked: which node wrote the entry, and whether `pki-wt/`'s issuers decrypt.

## Signed under the Root instead

The leaf was signed offline under the chibifire.com Root CA, the route the Windows session had
asked for, with the Root's key piped from 1Password and never written to disk:

    openssl x509 -req -in windows-156928.csr -CA root.pem \
        -CAkey <(op read "op://Personal/<chibifire.com Root CA>/private_key") \
        -set_serial 0x<random 16 bytes> -days 365 -sha256 -extfile leaf.ext

| Field | Value |
| --- | --- |
| Serial | `0x576fdee16baf58fcb75270f9710eacce` |
| Validity | 2026-10-01T06:17:46Z to 2027-10-01T06:17:46Z |
| Extensions | CA:FALSE; key usage digitalSignature, keyEncipherment; clientAuth; SAN as requested |
| Chain check | `openssl verify -CAfile root.pem`: OK; public key equal to the CSR's |

The Root has no subject key identifier, so the leaf's authority key identifier is empty.

## The role, and the Windows desk's login

With the root token from 1Password in one shell's environment, never printed or stored, and
the Mac desk's agent certificate for the mTLS handshake:

    bao write auth/cert/certs/windows-156928 display_name=windows-156928 \
        certificate=@ca-chain.pem allowed_common_names=windows-156928.chibifire.com \
        token_policies=agents-rw,default,github-pr,ssh-bao-tunnel \
        token_ttl=86400 token_max_ttl=604800

The read-back matched `fedora-cad853` but for the pinned name. The Windows session then checked
the chain locally (the Root's fingerprint `05:EE:AD:…:CA:41` matched its bundle; a same-name wrong
CA failed), logged in over Tailscale with `bao login -method=cert`, received
`cert-windows-156928` with the four policies and a 24 h TTL, and minted a GitHub token.

Unchecked: the Root's 1Password note records that its key once sat in plain text and is to be
treated as historically compromised; this leaf is re-issued with every other one when the Root
rotates.
