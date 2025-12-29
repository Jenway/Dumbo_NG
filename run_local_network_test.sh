#!/bin/sh

# 参数定义
# $1: N (总节点数)
# $2: f (容错数)
# $3: B (Batch Size)
# $4: C/K (测试轮数/Checkpoint)

if [ "$#" -lt 4 ]; then
    echo "Usage: ./run_local_network_test.sh <N> <F> <B> <K>"
    exit 1
fi

N=$1
F=$2
B=$3
K=$4

KEY_DIR="keys/keys-$N"
if [ ! -d "$KEY_DIR" ]; then
    echo "Key directory $KEY_DIR not found. Generating keys..."
    python3 run_trusted_key_gen.py --N "$N" --f "$F"
    if [ $? -ne 0 ]; then
        echo "Failed to generate keys."
        exit 1
    fi
else
    echo "Using existing keys in $KEY_DIR."
fi

echo "Cleaning up existing python3 processes..."
killall python3 2>/dev/null

i=0
while [ "$i" -lt $1 ]; do
    echo "start node $i..."
    # python3 run_socket_node.py --sid 'sidA' --id $i --N $1 --f $2 --B $3 --K $4 --S 100  --P "dumbo" --D True --O True &
    python3 run_socket_node.py --sid 'sidA' --id $i --N $1 --f $2 --B $3 --S 100 --P "ng" --D True --O True --C $4 &
    # python3 run_sockets_node.py --sid 'sidA' --id $i --N $1 --f $2 --B $3 --K $4 --S 100  --P "dl" --D True --O True &

    i=$(( i + 1 ))

done

wait
