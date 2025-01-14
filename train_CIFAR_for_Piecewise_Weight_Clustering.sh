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
test_batch_size=128
optimizer=SGD

label_info=PC

save_path=./save/${DATE}/${dataset}_${model}_${epochs}_${optimizer}_${label_info}
tb_path=${save_path}/tb_log  #tensorboard log path

############### Neural network ############################
{
python main.py --dataset ${dataset} \
    --data_path ${data_path}   \
    --arch ${model} --save_path ${save_path} \
    --epochs ${epochs} --learning_rate 0.1 \
    --optimizer ${optimizer} \
	--schedule 80 120  --gammas 0.1 0.1 \
    --attack_sample_size ${train_batch_size} \
    --test_batch_size ${test_batch_size} \
    --workers 4 --ngpu 1 --gpu_id 1 \
    --print_freq 100 --decay 0.0003 --momentum 0.9 \
    --clustering --lambda_coeff 1e-3    
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
