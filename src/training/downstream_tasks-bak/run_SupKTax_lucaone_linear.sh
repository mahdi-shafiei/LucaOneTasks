#!/bin/bash
export CUDA_VISIBLE_DEVICES=1

DATASET_NAME="SupKTax"
DATASET_TYPE="gene"
TASK_TYPE="multi_class"
TASK_LEVEL_TYPE="seq_level"
MODEL_TYPE="luca_base"
CONFIG_NAME="luca_base_config.json"
# channels: seq,vector,matrix,seq_matrix,seq_vector
INPUT_TYPE="matrix"
INPUT_MODE="single"
LABEL_TYPE="SupKTax"
FUSION_TYPE="concat"
embedding_input_size=2560
SEQ_MAX_LENGTH=1502
matrix_max_length=1502
TRUNC_TYPE="right"
hidden_size=1024
num_attention_heads=0
num_hidden_layers=0
dropout_prob=0.1
# none, avg, max, value_attention
SEQ_POOLING_TYPE="value_attention"
# none, avg, max, value_attention
MATRIX_POOLING_TYPE="value_attention"
VOCAB_NAME="gene_prot"
BEST_METRIC_TYPE="acc"
classifier_size=128
# binary-class, multi-label: bce, multi-class: cce, regression: l1 or l2
loss_type="cce"
llm_type="lucaone_gplm"
llm_task_level="token_level,span_level,seq_level,structure_level"
llm_version="v2.0"
llm_time_str=20231125113045
llm_step=5600000
batch_size=16
learning_rate=1e-4
gradient_accumulation_steps=2
time_str=$(date "+%Y%m%d%H%M%S")
cd ../../
python run.py \
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
  --alphabet gene_prot \
  --label_filepath ../dataset/$DATASET_NAME/$DATASET_TYPE/$TASK_TYPE/label.txt  \
  --output_dir ../models/$DATASET_NAME/$DATASET_TYPE/$TASK_TYPE/$MODEL_TYPE/$INPUT_TYPE/$time_str \
  --log_dir ../logs/$DATASET_NAME/$DATASET_TYPE/$TASK_TYPE/$MODEL_TYPE/$INPUT_TYPE/$time_str \
  --tb_log_dir ../tb-logs/$DATASET_NAME/$DATASET_TYPE/$TASK_TYPE/$MODEL_TYPE/$INPUT_TYPE/$time_str \
  --config_path ../config/$MODEL_TYPE/$CONFIG_NAME \
  --seq_vocab_path  gene_prot \
  --seq_pooling_type $SEQ_POOLING_TYPE \
  --matrix_pooling_type $MATRIX_POOLING_TYPE \
  --fusion_type $FUSION_TYPE \
  --do_train \
  --do_eval \
  --do_predict \
  --do_metrics \
  --evaluate_during_training \
  --per_gpu_train_batch_size=$batch_size \
  --per_gpu_eval_batch_size=$batch_size \
  --gradient_accumulation_steps=$gradient_accumulation_steps \
  --learning_rate=$learning_rate \
  --lr_update_strategy step \
  --lr_decay_rate 0.9 \
  --num_train_epochs=50 \
  --overwrite_output_dir \
  --seed 1221 \
  --loss_type $loss_type \
  --best_metric_type $BEST_METRIC_TYPE \
  --seq_max_length=$SEQ_MAX_LENGTH \
  --embedding_input_size $embedding_input_size \
  --matrix_max_length=$matrix_max_length \
  --trunc_type=$TRUNC_TYPE \
  --no_token_embeddings \
  --no_token_type_embeddings \
  --no_position_embeddings \
  --buffer_size 4096 \
  --delete_old \
  --llm_dir .. \
  --llm_type $llm_type \
  --llm_version $llm_version \
  --llm_task_level $llm_task_level \
  --llm_time_str $llm_time_str \
  --llm_step $llm_step \
  --ignore_index -100 \
  --hidden_size $hidden_size \
  --num_attention_heads $num_attention_heads \
  --num_hidden_layers $num_hidden_layers \
  --dropout_prob $dropout_prob \
  --classifier_size $classifier_size \
  --vector_dirpath ../../vectors/$DATASET_NAME/$DATASET_TYPE/$TASK_TYPE/$MODEL_TYPE/$llm_type/$llm_version/$llm_time_str/$llm_step  \
  --matrix_dirpath ../../matrices/$DATASET_NAME/$DATASET_TYPE/$TASK_TYPE/$MODEL_TYPE/$llm_type/$llm_version/$llm_time_str/$llm_step \
  --seq_fc_size null \
  --matrix_fc_size null \
  --vector_fc_size null \
  --emb_activate_func gelu \
  --fc_activate_func gelu \
  --classifier_activate_func gelu \
  --warmup_steps 100 \
  --beta1 0.9 \
  --beta2 0.98 \
  --weight_decay 0.01 \
  --save_steps -1 \
  --logging_steps 200 \
  --loss_reduction mean



