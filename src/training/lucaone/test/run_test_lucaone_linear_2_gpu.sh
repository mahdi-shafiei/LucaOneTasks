#!/bin/bash
export CUDA_VISIBLE_DEVICES=0,1
seed=1221

# for dataset
DATASET_NAME="Test"
DATASET_TYPE="gene"

# for task
TASK_TYPE="binary_class"
TASK_LEVEL_TYPE="seq_level"
LABEL_TYPE="Test"

# for input
## here only embedding matrix-channel
## channels: seq,vector,matrix,seq_matrix,seq_vector
INPUT_TYPE="matrix"
INPUT_MODE="single"
TRUNC_TYPE="right"

# for model
MODEL_TYPE="luca_base"
CONFIG_NAME="luca_base_config.json"
FUSION_TYPE="concat"
dropout_prob=0.1
fc_size=128
classifier_size=$fc_size
BEST_METRIC_TYPE="f1"
# binary-class, multi-label: bce, multi-class: cce, regression: l1 or l2
loss_type="bce"

# for sequence channel
SEQ_MAX_LENGTH=10242
hidden_size=1024
num_attention_heads=8
num_hidden_layers=4
# none, avg, max, value_attention
SEQ_POOLING_TYPE="value_attention"
VOCAB_NAME="gene_prot"

# for embedding channel
embedding_input_size=2560
matrix_max_length=10242
# none, avg, max, value_attention
MATRIX_POOLING_TYPE="value_attention"
# When the input sequence is too long for your GPU to complete the inference at once, you can specify the fixed length of the inference at once
embedding_fixed_len_a_time=4096

# for llm
llm_type="lucaone"
llm_version="lucaone"
# llm_step=5600000
llm_step=36000000

# for training
## max epochs
num_train_epochs=50
## accumulation gradient steps
gradient_accumulation_steps=16
# 间隔多少个step在log文件中写入信息（实际上是gradient_accumulation_steps与logging_steps的最小公倍数）
logging_steps=1000
## checkpoint的间隔step数。-1表示按照epoch粒度保存checkpoint
save_steps=-1
## warmup_steps个step到达peak lr
warmup_steps=1000
## 最大迭代step次数(这么多次后，peak lr1变为lr2, 需要根据epoch,样本数量,n_gpu,batch_size,gradient_accumulation_steps进行估算）
## -1自动计算
max_steps=-1
## batch size for one GPU
batch_size=1
## 最大学习速率(peak learning rate)
learning_rate=1e-4
## data loading buffer size
buffer_size=512
# pos weight
pos_weight=2.0

time_str=$(date "+%Y%m%d%H%M%S")
cd ../../../
python -W ignore -m torch.distributed.launch --nnodes 1 --node_rank 0 --master_port=25687 --nproc_per_node=2 \
  run.py \
  --train_data_dir ../dataset/$DATASET_NAME/$DATASET_TYPE/$TASK_TYPE/train/ \
  --dev_data_dir ../dataset/$DATASET_NAME/$DATASET_TYPE/$TASK_TYPE/dev/ \
  --test_data_dir ../dataset/$DATASET_NAME/$DATASET_TYPE/$TASK_TYPE/test/ \
  --dataset_name $DATASET_NAME \
  --dataset_type $DATASET_TYPE \
  --task_type $TASK_TYPE \
  --task_level_type $TASK_LEVEL_TYPE \
  --model_type $MODEL_TYPE \
  --input_type $INPUT_TYPE \
  --input_mode $INPUT_MODE \
  --label_type $LABEL_TYPE \
  --alphabet $VOCAB_NAME \
  --label_filepath ../dataset/$DATASET_NAME/$DATASET_TYPE/$TASK_TYPE/label.txt  \
  --output_dir ../models/$DATASET_NAME/$DATASET_TYPE/$TASK_TYPE/$MODEL_TYPE/$INPUT_TYPE/$time_str \
  --log_dir ../logs/$DATASET_NAME/$DATASET_TYPE/$TASK_TYPE/$MODEL_TYPE/$INPUT_TYPE/$time_str \
  --tb_log_dir ../tb-logs/$DATASET_NAME/$DATASET_TYPE/$TASK_TYPE/$MODEL_TYPE/$INPUT_TYPE/$time_str \
  --config_path ../config/$MODEL_TYPE/$CONFIG_NAME \
  --seq_vocab_path $VOCAB_NAME \
  --seq_pooling_type $SEQ_POOLING_TYPE \
  --matrix_pooling_type $MATRIX_POOLING_TYPE \
  --fusion_type $FUSION_TYPE \
  --do_train \
  --do_eval \
  --do_predict \
  --do_metrics \
  --evaluate_during_training \
  --per_gpu_train_batch_size=$batch_size \
  --per_gpu_eval_batch_size=$batch_size  \
  --gradient_accumulation_steps=$gradient_accumulation_steps \
  --learning_rate=$learning_rate \
  --lr_update_strategy step \
  --lr_decay_rate 0.95 \
  --num_train_epochs=$num_train_epochs \
  --overwrite_output_dir \
  --seed $seed \
  --loss_type $loss_type \
  --best_metric_type $BEST_METRIC_TYPE \
  --seq_max_length=$SEQ_MAX_LENGTH \
  --embedding_input_size $embedding_input_size \
  --matrix_max_length=$matrix_max_length \
  --trunc_type=$TRUNC_TYPE \
  --no_token_embeddings \
  --no_token_type_embeddings \
  --no_position_embeddings \
  --pos_weight $pos_weight \
  --buffer_size $buffer_size \
  --save_all \
  --llm_dir .. \
  --llm_type $llm_type \
  --llm_version $llm_version \
  --llm_step $llm_step \
  --ignore_index -100 \
  --hidden_size $hidden_size \
  --num_attention_heads $num_attention_heads \
  --num_hidden_layers $num_hidden_layers \
  --dropout_prob $dropout_prob \
  --classifier_size $classifier_size \
  --vector_dirpath ../../vectors/$DATASET_NAME/$llm_type/$llm_version/$llm_step  \
  --matrix_dirpath ../../matrices/$DATASET_NAME/$llm_type/$llm_version/$llm_step  \
  --seq_fc_size null \
  --matrix_fc_size null \
  --vector_fc_size null \
  --emb_activate_func gelu \
  --fc_activate_func gelu \
  --classifier_activate_func gelu \
  --warmup_steps $warmup_steps \
  --beta1 0.9 \
  --beta2 0.98 \
  --weight_decay 0.01 \
  --save_steps $save_steps \
  --max_steps $max_steps \
  --logging_steps $logging_steps \
  --loss_reduction mean \
  --matrix_add_special_token \
  --embedding_complete \
  --embedding_complete_seg_overlap \
  --embedding_fixed_len_a_time $embedding_fixed_len_a_time