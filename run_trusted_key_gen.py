from crypto.threshsig import boldyreva
from crypto.threshenc import tpke
from crypto.ecdsa import ecdsa
from pathlib import Path
import pickle
import os

def trusted_key_gen(N=4, f=1, seed=None):

    # Generate threshold enc keys
    ePK, eSKs = tpke.dealer(N, f+1)

    # Generate threshold sig keys for coin (thld f+1)
    sPK, sSKs = boldyreva.dealer(N, f+1, seed=seed)

    # Generate threshold sig keys for cbc (thld n-f)
    sPK1, sSK1s = boldyreva.dealer(N, N-f, seed=seed)

    # Generate ECDSA sig keys
    sPK2s, sSK2s = ecdsa.pki(N)

    # Save all keys to files
    base_keys_path = Path.cwd() / "keys"
    key_dir = base_keys_path / f"keys-{N}"
    key_dir.mkdir(parents=True, exist_ok=True)

    # public key of (f+1, n) thld sig
    (key_dir / "sPK.key").write_bytes(pickle.dumps(sPK))
    # public key of (n-f, n) thld sig
    (key_dir / "sPK1.key").write_bytes(pickle.dumps(sPK1))
    # public key of (f+1, n) thld enc
    (key_dir / "ePK.key").write_bytes(pickle.dumps(ePK))

    for i in range(N):
        # public keys of ECDSA
        (key_dir / f"sPK2-{i}.key").write_bytes(pickle.dumps(sPK2s[i].format()))

        # private key of (f+1, n) thld sig
        (key_dir / f"sSK-{i}.key").write_bytes(pickle.dumps(sSKs[i]))

        # private key of (n-f, n) thld sig
        (key_dir / f"sSK1-{i}.key").write_bytes(pickle.dumps(sSK1s[i]))

        # private key of (f+1, n) thld enc
        (key_dir / f"eSK-{i}.key").write_bytes(pickle.dumps(eSKs[i]))

        # private keys of ECDSA
        (key_dir / f"sSK2-{i}.key").write_bytes(pickle.dumps(sSK2s[i].secret))
        
if __name__ == '__main__':
    
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--N', metavar='N', required=True,
                        help='number of parties', type=int)
    parser.add_argument('--f', metavar='f', required=True,
                        help='number of faulties', type=int)
    args = parser.parse_args()

    N = args.N
    f = args.f

    assert N >= 3 * f + 1

    trusted_key_gen(N, f)



if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Trusted Key Generator for BFT Consensus")
    parser.add_argument('--N', required=True, type=int, help='Total number of parties')
    parser.add_argument('--f', required=True, type=int, help='Number of faulty parties')
    args = parser.parse_args()

    if args.N < 3 * args.f + 1:
        raise ValueError(f"N must be at least 3f+1. Current N={args.N}, f={args.f}")

    trusted_key_gen(args.N, args.f)
