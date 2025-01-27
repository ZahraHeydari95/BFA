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
model=resnet18_quan
dataset=cifar10
epochs=10
train_batch_size=128
test_batch_size=100
optimizer=SGD

label_info=new_exp

attack_sample_size=128 # number of data used for BFA
n_iter=3 # number of iteration to perform BFA
k_top=10 # only check k_top weights with top gradient ranking in each layer


save_path=./save/${DATE}/${dataset}_${model}_${label_info}
tb_path=./save/${DATE}/${dataset}_${model}_${label_info}/tb_log  #tensorboard log path

# set the pretrained model path
pretrained_model=/content/BFA/save/2022-11-15/cifar10_resnet18_quan_10_SGD_PC/checkpoint.pth.tar
  #tensorboard log path

############### Neural network ############################
{
python main.py --dataset ${dataset} \
    --data_path ${data_path}   \
    --arch ${model} --save_path ${save_path} \
    --epochs ${epochs} --learning_rate 0.1 \
    --optimizer ${optimizer} \
	--schedule 80 120  --gammas 0.1 0.1 \
    --test_batch_size ${test_batch_size} \
    --workers 4 --ngpu 1 --gpu_id 1 \
    --print_freq 100 --decay 0.0003 --momentum 0.9 \
    --evaluate --resume ${pretrained_model} --fine_tune \
    --attack_sample_size ${attack_sample_size}
    --reset_weight --bfa --n_iter ${n_iter} --k_top ${k_top} \
    
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
