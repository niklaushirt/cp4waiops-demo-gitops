#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#       __________  __ ___       _____    ________            
#      / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____
#     / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/
#    / /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) 
#    \____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  
#                                              /_/            
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------------------"
#  Load Robotshop Data for Training for CP4WAIOPS 3.2
#
#  CloudPak for Watson AIOps
#
#  ©2021 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------------------------------------------"
clear

echo "   __________  __ ___       _____    ________            "
echo "  / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____"
echo " / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/"
echo "/ /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) "
echo "\____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  "
echo "                                          /_/            "
echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  🚀 CloudPak for Watson AI OPS 3.1 - Load Robotshop Data for Training "
echo "  "
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "  "
echo "  "


export ANSIBLE_DISPLAY_SKIPPED_HOSTS=false



echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo "  "
echo "  🚀 Start loading data for ChangeRisk and SimilarIncidents Training"
echo "  "
echo "***************************************************************************************************************************************************"
echo "  "
echo "  "
echo "  "


# Load the ES Indexes for Changerisk and Similar Incidents Training
#---------------------------------------------------------------------
./tools/02_training/robotshop-load-snow-for-training.sh



echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "***************************************************************************************************************************************************"
echo "  "
echo "  🚀 Start loading data for Log Anomaly Training"
echo "  "
echo "***************************************************************************************************************************************************"
echo "  "
echo "  "
echo "  "

# Load the ES Indexes for Log Training 
#---------------------------------------------------------------------
# Unzip Log Training Data
cd ./tools/02_training/TRAINING_FILES/ELASTIC/robot-shop/logs/
unzip *
cd -

# Load the ES Indexes for Log Training 
./tools/02_training/robotshop-load-logs-for-training.sh

# Remove unzipped Log Training Data
rm ./tools/02_training/TRAINING_FILES/ELASTIC/robot-shop/logs/*.json



echo "***************************************************************************************************************************************************"
echo "  "
echo "  🗺 Log Anomaly Training Mapping"
echo "  "
echo "***************************************************************************************************************************************************"
echo "  "
echo "  "
echo "  "

echo "{"
echo "  \"codec\": \"humio\","
echo "  \"message_field\": \"@rawstring\","
echo "  \"log_entity_types\": \"kubernetes.namespace_name,kubernetes.container_hash,kubernetes.host,kubernetes.container_name,kubernetes.pod_name\","
echo "  \"instance_id_field\": \"kkubernetes.container_name\","
echo "  \"rolling_time\": 10,"
echo "  \"timestamp_field\": \"@timestamp\""
echo "}"
