# Defending and Harnessing the Bit-Flip based Adversarial Weight Attack
# CVPR2020 paper

# Implemented with changes on google colab by zahra heydari
# IPM



#  Bit-Flips Attack and Defense

##  Introduction
  
  
This repository includes a Bit-Flip Attack (BFA) algorithm which search and identify the vulernable bits within a quantized deep neural network.
On the other hand, it contains two methods to deal with bit-flip attack.
1- Binarization-aware training
2- Clustering as relaxation of binarization (PC)

##  Dependencies
 
* Python 
* Pytorch >=1.01
* TensorboardX 
* conda
* install Requirement.txt file

  
##  Usage
  
###  1. Configurations
  
Please modify `TENSORBOARD=` and `data_path=` in the example bash codes before running the code.
  
```bash
HOST=$(hostname)
echo "Current host is: $HOST"
  
# Automatic check the host and configuration
case $HOST in
"alpha") # alpha is the hostname
    TENSORBOARD='-----/-----/----' # tensorboard environment path
    data_path='----/----/----' # cifar10 dataset path
    ;;
esac
```
  
###  2. Perform the BFA
  
####  2.1 Attack on the model trained in floating-point.
  
  
#####  Example of ResNet-18 on CIFAR10
  
> __Note__: Keep the bit-width of weight quantization as 8-bit.
  

```bash
$ bash BFA_imagenet.sh
```
  

#####  How to perform random bit-flips on a given model?
  
  
The random attack is performed on all the possible weight bit (regardless MSB to LSB). Take the above MobileNet-v2 as example, you just need to add another line to enable the random bit flip `--random_bfa` in `BFA_imagent.sh`:
```bash
    ...
    --attack_sample_size ${attack_sample_size} \
    --random_bfa
    ...
```
  
####  2.2 Training-based BFA defense
  
  
#####  Binarization-aware training
  
  
Taken the ResNet-20 on CIFAR-10 as example:
  
1. Define a binarized ResNet20 in `models/quan_resnet_cifar.py`.
2. To use the weight binariztaion function. Comment out multi-bit quantization. (copy file quantization-binariztaion.py from models folder in quantization.py)
3. Perform the model training, where the binarized model is initialized in `models/__init__.py` as `resnet18_quan`. Then run `bash train_CIFAR.sh`  in terminal (Don't forget the path configuration!).
  
4. With binarized model trained and stored at `<path-to-model>/model_best.pth.tar`, make sure the following changes in the `BFA_CIFAR.sh`:
```bash
pretrained_model='<path-to-model>/model_best.pth.tar'
```
  
#####  Piecewise Weight Clustering
  
  
> The piecewise weight clutering should not be applied on the binarized NN. 
  
1. Make sure ```models/quantization.py``` use the multi-bit quantization, in constrast to the binarized counterpart. To change the bit-width, please access the code in ```models/quantization.py```. Under the definition of ```quan_Conv2d``` and ```quan_Linear```, change the arg ```self.N_bits = 8``` if you want 8-bit quantization.
  
2. In `train_CIFAR.sh`, enable (i.e., uncomment) the following command:
```bash
--clustering --lambda_coeff 1e-3
```
Then train the model by `bash train_CIFAR.sh`.
  
3. For the BFA evaluation, please refer the binarization case.
  
  
  
##  License
  
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
  
The software is for educaitonal and academic research purpose only.
  
