#!/usr/bin/env sh

############### Host   ##############################
HOST=$(hostname)
echo "Current host is: $HOST"

# Automatic check the host and configuration
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
model=resnet18
dataset=cifar10
test_batch_size=256

save_path=./save/${DATE}/${dataset}_${model}_eval/

tb_path=${save_path}/tb_log  #tensorboard log path

############### Neural network ############################
{
python main.py --dataset ${dataset} \
    --data_path ${data_path}   \
    --arch ${model} --save_path ${save_path} \
    --test_batch_size ${test_batch_size} \
    --workers 8 --ngpu 1 --gpu_id 1 \
    --evaluate
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
