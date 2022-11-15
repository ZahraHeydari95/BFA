#!/usr/bin/env sh

############### Host   ##############################
HOST=$(hostname)
echo "Current host is: $HOST"

# Automatic check the host and configure
case $HOST in
"alpha")
    TENSORBOARD='/usr/local/bin/tensorboard' # tensorboard environment path
    data_path='/content/data/cifar-10-batches-py'
    ;;
esac

DATE=`date +%Y-%m-%d`

mkdir save
cd save 
mkdir ${DATE}
cd ..

############### Configurations ########################
enable_tb_display=false # enable tensorboard display
model=resnet20_quan
dataset=cifar10
test_batch_size=128

label_info=BFA_defense_test_binarized

attack_sample_size=128 # number of data used for BFA
n_iter=50 # number of iteration to perform BFA
k_top=100 # only check k_top weights with top gradient ranking in each layer

save_path=./save/${DATE}/${dataset}_${model}_${label_info}
tb_path=${save_path}/tb_log  #tensorboard log path

# set the pretrained model path
pretrained_model=/content/BFA/save/2022-11-15/cifar10_resnet18_quan_10_SGD_binarized/checkpoint.pth.tar

############### Neural network ############################
COUNTER=0
{
while [ $COUNTER -lt 1 ]; do
    python main.py --dataset ${dataset} \
        --data_path ${data_path}   \
        --arch ${model} --save_path ${save_path}  \
        --test_batch_size ${test_batch_size} --workers 8 --ngpu 1 --gpu_id 1 \
        --print_freq 50 \
        --evaluate --resume ${pretrained_model} --fine_tune\
        --reset_weight --bfa --n_iter ${n_iter} \
        --attack_sample_size ${attack_sample_size} \

    let COUNTER=COUNTER+1
done
} &
############## Tensorboard logging ##########################
{
if [ "$enable_tb_display" = true ]; then 
    sleep 30 
    wait
    $TENSORBOARD --logdir $tb_path  --port=6006
fi
} &
{
if [ "$enable_tb_display" = true ]; then
    sleep 45
    wait
    case $HOST in
    "Hydrogen")
        firefox http://0.0.0.0:6006/
        ;;
    "alpha")
        google-chrome http://0.0.0.0:6006/
        ;;
    esac
fi 
} &
wait
