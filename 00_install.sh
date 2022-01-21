#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#       __________  __ ___       _____    ________            
#      / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____
#     / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/
#    / /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) 
#    \____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  
#                                              /_/            
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------"
#  CP4WAIOPS 3.2 - CP4WAIOPS Installation
#
#
#  ©2022 nikh@ch.ibm.com
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
clear

echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "  "
echo "  🚀 CloudPak for Watson AIOps 3.2 - CP4WAIOps Installation"
echo "  "
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "  "
echo "  "


export TEMP_PATH=~/aiops-install

# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"
# Do Not Edit Below
# ---------------------------------------------------------------------------------------------------------------"
# ---------------------------------------------------------------------------------------------------------------"



if [ ! -x "$(command -v oc)" ]; then
      echo "❌ Openshift Client not installed."
      echo "   🚀 Install prerequisites with ./argocd/scripts/02-prerequisites-mac.sh or ./argocd/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi
if [ ! -x "$(command -v jq)" ]; then
      echo "❌ jq not installed."
      echo "   🚀 Install prerequisites with ./argocd/scripts/02-prerequisites-mac.sh or ./argocd/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi
if [ ! -x "$(command -v argocd)" ]; then
      echo "❌ argocd not installed."
      echo "   🚀 Install prerequisites with ./argocd/scripts/02-prerequisites-mac.sh or ./argocd/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi
if [ ! -x "$(command -v cloudctl)" ]; then
      echo "❌ argocd not installed."
      echo "   🚀 Install prerequisites with ./argocd/scripts/02-prerequisites-mac.sh or ./argocd/scripts/03-prerequisites-ubuntu.sh"
      echo "❌ Aborting...."
      exit 1
fi


export CLUSTER_STATUS=$(oc status | grep "In project")
export CLUSTER_WHOAMI=$(oc whoami)

if [[ ! $CLUSTER_STATUS =~ "In project" ]]; then
      echo "❌ You are not logged into a Openshift Cluster."
      echo "❌ Aborting...."
      exit 1
else
      echo "✅ $CLUSTER_STATUS"
      echo "   as user $CLUSTER_WHOAMI"

fi

echo ""
echo ""
echo ""
echo ""

echo "  Initializing"
export ARGOCD_NAMESPACE=$(oc get po -n openshift-gitops --ignore-not-found|grep openshift-gitops-server |awk '{print$1}')
echo "  ........."
export WAIOPS_NAMESPACE=$(oc get po -A|grep aimanager-operator |awk '{print$1}')
echo "  o........"
export EVTMGR_NAMESPACE=$(oc get po -A|grep noi-operator |awk '{print$1}')
echo "  oo......."
export RS_NAMESPACE=$(oc get ns robot-shop  --ignore-not-found|awk '{print$1}')
echo "  ooo......"
export TURBO_NAMESPACE=$(oc get ns turbonomic  --ignore-not-found|awk '{print$1}')
echo "  oooo....."
export AWX_NAMESPACE=$(oc get ns awx  --ignore-not-found|awk '{print$1}')
echo "  ooooo...."
export LDAP_NAMESPACE=$(oc get po -n default --ignore-not-found| grep ldap |awk '{print$1}')
echo "  oooooo..."
export DEMO_NAMESPACE=$(oc get po -A|grep demo-ui- |awk '{print$1}')
echo "  ooooooo.."
export ELK_NAMESPACE=$(oc get ns openshift-logging  --ignore-not-found|awk '{print$1}')
echo "  oooooooo."
export ISTIO_NAMESPACE=$(oc get ns istio-logging  --ignore-not-found|awk '{print$1}')
echo "  ooooooooo"
export HUMIO_NAMESPACE=$(oc get ns humio-logging  --ignore-not-found|awk '{print$1}')
echo "  ✅ Done"





# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
# Patch IAF Resources for ROKS
# ------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------
menu_INSTALL_AIMGR () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install CP4WAIOPS AI Manager" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""
      if [[ ! $WAIOPS_NAMESPACE == "" ]]; then
            echo "❗⚠️ CP4WAIOPS AI Manager seems to be installed already"

            read -p " ❗❓ Are you sure you want to continue? [y,N] " DO_COMM
            if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
                  echo "   ✅ Ok, continuing..."
                  echo ""
                  echo ""

            else
                  echo "    ❌ Aborting"
                  echo "--------------------------------------------------------------------------------------------"
                  echo  ""    
                  echo  ""
                  exit 1
            fi

      fi

      echo ""
      echo ""
      echo "  Enter CP4WAIOPS Pull token: "
      read TOKEN
      echo ""
      echo "You have entered the following Token:"
      echo $TOKEN
      echo ""
      read -p " ❗❓ Are you sure that this is correct? [y,N] " DO_COMM
      if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            read -p " ❗❓ Do you want to install demo content (highly recommended - OpenLdap and RobotShop)? [Y,n] " DO_COMM
            if [[ $DO_COMM == "n" ||  $DO_COMM == "N" ]]; then
                  echo "   ✅ Ok, continuing without demo content..."
                  echo ""
                  echo ""

                  echo ""
                  oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"core.aiManager.aiManagerInstall","value":"true"}}]'
                  oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"core.aiManager.aiManagerPullToken","value":"'$TOKEN'"}}]'
                  argocd app sync installer
            else
                  echo "   ✅ Ok, continuing with demo content..."
                  echo ""
                  echo ""

                  echo ""

                  oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"core.aiManager.aiManagerInstall","value":"true"}}]'
                  oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"core.aiManager.aiManagerPullToken","value":"'$TOKEN'"}}]'
                  oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"addons.LDAPInstall","value":"true"}}]'
                  oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"addons.RobotShopInstall","value":"true"}}]'
                  argocd app sync installer

            fi
      else
            echo "    ⚠️  Skipping"
            echo "--------------------------------------------------------------------------------------------"
            echo  ""    
            echo  ""
      fi
}




menu_INSTALL_EVTMGR () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install CP4WAIOPS Event Manager" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""
      if [[ ! $EVTMGR_NAMESPACE == "" ]]; then
            echo "❗⚠️ CP4WAIOPS Event Manager seems to be installed already"

            read -p " ❗❓ Are you sure you want to continue? [y,N] " DO_COMM
            if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
                  echo "   ✅ Ok, continuing..."
                  echo ""
                  echo ""

            else
                  echo "    ❌ Aborting"
                  echo "--------------------------------------------------------------------------------------------"
                  echo  ""    
                  echo  ""
                  exit 1
            fi

      fi

      echo ""
      echo ""
      echo "  Enter CP4WAIOPS Pull token: "
      read TOKEN
      echo ""
      echo "You have entered the following Token:"
      echo $TOKEN
      echo ""
      read -p " ❗❓ Are you sure that this is correct? [y,N] " DO_COMM
      if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
            echo ""

            echo ""
            oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"core.eventManager.eventManagerInstall","value":"true"}}]'
            oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"core.eventManager.eventManagerPullToken","value":"'$TOKEN'"}}]'
            argocd app sync installer

      else
            echo "    ⚠️  Skipping"
            echo "--------------------------------------------------------------------------------------------"
            echo  ""    
            echo  ""
      fi
}





menu_INSTALL_AIOPSDEMO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install CP4WAIOPSDemoUI" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      helmValue=CP4WAIOPSDemoUIInstall
      echo "Patching"$helmValue
      oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"addons.'$helmValue'","value":"true"}}]'
      argocd app sync installer

}


menu_INSTALL_ROBOTSHOP () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install RobotShop" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      helmValue=RobotShopInstall
      echo "Patching"$helmValue
      oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"addons.'$helmValue'","value":"true"}}]'
      argocd app sync installer
}


menu_INSTALL_LDAP () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install LDAP" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      helmValue=LDAPInstall
      echo "Patching"$helmValue
      oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"addons.'$helmValue'","value":"true"}}]'
      argocd app sync installer
}

menu_INSTALL_TURBO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install Turbonomic" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      helmValue=TurbonomicInstall
      echo "Patching"$helmValue
      oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"solutions.'$helmValue'","value":"true"}}]'
      argocd app sync installer
}


menu_INSTALL_AWX () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install AWX" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      helmValue=AWXInstall
      echo "Patching"$helmValue
      oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"solutions.'$helmValue'","value":"true"}}]'
      argocd app sync installer
}




menu_INSTALL_ELK () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install OpenShift Logging" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      helmValue=ELKInstall
      echo "Patching"$helmValue
      oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"solutions.'$helmValue'","value":"true"}}]'
      argocd app sync installer
}



menu_INSTALL_ISTIO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install OpenShift Mesh" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""

      helmValue=IstioInstall
      echo "Patching"$helmValue
      oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"solutions.'$helmValue'","value":"true"}}]'
      argocd app sync installer
}



menu_INSTALL_HUMIO () {
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀  Install Humio" 
      echo "--------------------------------------------------------------------------------------------"
      echo ""
      if [[ ! $HUMIO_NAMESPACE == "" ]]; then
            echo "❗⚠️ Humio seems to be installed already"

            read -p " ❗❓ Are you sure you want to continue? [y,N] " DO_COMM
            if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
                  echo "   ✅ Ok, continuing..."
                  echo ""
                  echo ""

            else
                  echo "    ❌ Aborting"
                  echo "--------------------------------------------------------------------------------------------"
                  echo  ""    
                  echo  ""
                  exit 1
            fi

      fi

      echo ""
      echo ""
      echo "  Enter Humio License: "
      read TOKEN
      echo ""
      echo "You have entered the following license:"
      echo $TOKEN
      echo ""
      read -p " ❗❓ Are you sure that this is correct? [y,N] " DO_COMM
      if [[ $DO_COMM == "y" ||  $DO_COMM == "Y" ]]; then
            echo "   ✅ Ok, continuing..."
            echo ""
            echo ""

            echo ""
            helmValue=HumioInstall
            helmLicense=HumioLicense
            echo "Patching"$helmValue
            oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"solutions.'$helmValue'","value":"true"}}]'
            oc patch applications.argoproj.io -n openshift-gitops installer --type=json -p='[{"op": "add", "path": "/spec/source/helm/parameters/-", "value":{"name":"solutions.'$helmLicense'","value":'$TOKEN'}}]'
            argocd app sync installer

            

      else
            echo "    ⚠️  Skipping"
            echo "--------------------------------------------------------------------------------------------"
            echo  ""    
            echo  ""
      fi
}


menu_LOGIN_ARGO(){

      export ARGOCD_URL=$(oc get route -n  openshift-gitops  openshift-gitops-server -o jsonpath={.spec.host})
      export ARGOCD_USER=admin
      export ARGOCD_PWD=$(oc get secret -n openshift-gitops openshift-gitops-cluster -o "jsonpath={.data['admin\.password']}"| base64 --decode)

      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀 Logging In" 
      echo "--------------------------------------------------------------------------------------------"
      argocd login $ARGOCD_URL --insecure --username $ARGOCD_USER --password $ARGOCD_PWD
      
   
}


menu_APPS_ARGO(){

      export ARGOCD_URL=$(oc get route -n  openshift-gitops  openshift-gitops-server -o jsonpath={.spec.host})
      export ARGOCD_USER=admin
      export ARGOCD_PWD=$(oc get secret -n openshift-gitops openshift-gitops-cluster -o "jsonpath={.data['admin\.password']}"| base64 --decode)

      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀 Logging In" 
      echo "--------------------------------------------------------------------------------------------"
      argocd login $ARGOCD_URL --insecure --username $ARGOCD_USER --password $ARGOCD_PWD
      
      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀 ArgoCD Applications" 
      echo "--------------------------------------------------------------------------------------------"
      argocd app list


      echo "--------------------------------------------------------------------------------------------"
      echo " 🚀 ArgoCD Repos" 
      echo "--------------------------------------------------------------------------------------------"
      argocd repo list

}

incorrect_selection() {
      echo "--------------------------------------------------------------------------------------------"
      echo " ❗ This option does not exist!" 
      echo "--------------------------------------------------------------------------------------------"
}


clear

echo "***************************************************************************************************************************************************"
echo "***************************************************************************************************************************************************"
echo "      __________  __ ___       _____    ________            "
echo "     / ____/ __ \/ // / |     / /   |  /  _/ __ \____  _____"
echo "    / /   / /_/ / // /| | /| / / /| |  / // / / / __ \/ ___/"
echo "   / /___/ ____/__  __/ |/ |/ / ___ |_/ // /_/ / /_/ (__  ) "
echo "   \____/_/      /_/  |__/|__/_/  |_/___/\____/ .___/____/  "
echo "                                             /_/            "
echo "***************************************************************************************************************************************************"


echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo " 🚀 CloudPak for Watson AIOPs - INSTALL"
echo "*****************************************************************************************************************************"
echo "  "
echo "  ℹ️  This script provides different options to install CP4WAIOPS demo environments through OpenShift GitOps(ArgoCD)"
echo ""
echo ""

if [[  $ARGOCD_NAMESPACE =~ "openshift-gitops" ]]; then

      export ARGOCD_URL=$(oc get route -n  openshift-gitops  openshift-gitops-server -o jsonpath={.spec.host})
      export ARGOCD_USER=admin
      export ARGOCD_PWD=$(oc get secret -n openshift-gitops openshift-gitops-cluster -o "jsonpath={.data['admin\.password']}"| base64 --decode)

      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    🚀 Connect to OpenShift GitOps to check your deployments"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    -----------------------------------------------------------------------------------------------------------------------------------------------"
      echo "    "
      echo "    🌏 URL:      https://$ARGOCD_URL"
      echo "  "
      echo "    🧔 User:       $ARGOCD_USER"
      echo "    🔐 Password:   $ARGOCD_PWD"
      echo "  "
      argocd login $ARGOCD_URL --insecure --username $ARGOCD_USER --password $ARGOCD_PWD

fi

echo "  "
echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "  "




until [ "$selection" = "0" ]; do
  
  echo ""
  

echo "  📥 Prerequisites Install"
if [[ ! $ARGOCD_NAMESPACE =~ "openshift-gitops" ]]; then
      echo "    	1  - Install Openshift GitOps                                 - Install OpenShift GitOps/ArgoCD"
else
      echo "    	✅  - Install Openshift GitOps                                "
fi

echo "    	2  - Install Prerequisites Mac                                - Install Prerequisites for Mac"
echo "    	3  - Install Prerequisites Ubuntu                             - Install Prerequisites for Ubuntu"
echo "  "
if [[ $ARGOCD_NAMESPACE =~ "openshift-gitops" ]]; then

      echo "  🚀 CP4WAIOPS - Base Install"
      if [[ $WAIOPS_NAMESPACE == "" ]]; then
            echo "    	11  - Install AI Manager                                      - Install CP4WAIOPS AI Manager Component"
      else
            echo "    	✅  - Install AI Manager                                      "
      fi

      if [[ ! $EVTMGR_NAMESPACE =~ "openshift-gitops" ]]; then
            echo "    	12  - Install Event Manager                                   - Install CP4WAIOPS Event Manager Component"
      else
            echo "    	✅  - Install Event Manager                                   "
      fi

      echo "  "
      echo "  🌏 Solutions"

      if [[ $TURBO_NAMESPACE == "" ]]; then
            echo "    	21  - Install Turbonomic                                      - Install Turbonomic (needs a separate license)"
      else
            echo "    	✅  - Install Turbonomic                                      "
      fi

      if [[  $HUMIO_NAMESPACE == "" ]]; then
            echo "    	22  - Install Humio                                           - Install Humio (needs a separate license)"
      else
            echo "    	✅  - Install Humio                                           "
      fi


      if [[  $AWX_NAMESPACE == "" ]]; then
            echo "    	23  - Install AWX                                             - Install AWX (open source Ansible Tower)"
      else
            echo "    	✅  - Install AWX                                             "
      fi

      if [[  $ISTIO_NAMESPACE == "" ]]; then
            echo "    	24  - Install OpenShift Mesh                                  - Install OpenShift Mesh (Istio)"
       else
            echo "    	✅  - Install OpenShift Mesh                                  "
       fi



      if [[  $ISTIO_NAMESPACE == "" ]]; then
            echo "    	25  - Install OpenShift Logging                               - Install OpenShift Logging (ELK)"
       else
            echo "    	✅  - Install OpenShift Logging                                 "
       fi


      echo "  "
      echo "  📛 CP4WAIOPS Addons"


      if [[  $DEMO_NAMESPACE == "" ]]; then
            echo "    	31  - Install CP4WAIOPS Demo Application                      - Install CP4WAIOPS Demo Application"
      else
            echo "    	✅  - Install CP4WAIOPS Demo Application                      "
      fi


      if [[  $LDAP_NAMESPACE == "" ]]; then
            echo "    	32  - Install OpenLdap                                        - Install OpenLDAP for CP4WAIOPS (should be installed by option 10)"
      else
            echo "    	✅  - Install OpenLdap                                        "
      fi

      if [[  $RS_NAMESPACE == "" ]]; then
            echo "    	33  - Install RobotShop                                       - Install RobotShop for CP4WAIOPS (should be installed by option 10)"
      else
            echo "    	✅  - Install RobotShop                                       "
      fi

            #       echo "    	25  - Install OpenShift Logging                               - Install OpenShift Logging (ELK)"
      echo "  "
      echo "  🔎 Openshift Gitops/ArgoCD"
      echo "    	41  - Login to ArgoCD                                        "
      echo "    	42  - ArgoCD List Applications                                     "


else
echo "***************************************************************************************************************************************************"

      echo "  ❗ All other options are disabled until OpenShift GitOps has been  installed"
      echo "***************************************************************************************************************************************************"

fi
  echo "      "
  echo "      "
  echo "      "
  echo "    	0  -  Exit"
  echo ""
  echo ""
  echo "  Enter selection: "
  read selection
  echo ""
  case $selection in
    1 ) clear ; ./argocd/01-install-gitops.sh  ;;
    2 ) clear ; ./argocd/scripts/02-prerequisites-mac.sh  ;;
    3 ) clear ; ./argocd/scripts/03-prerequisites-ubuntu.sh  ;;
    11 ) clear ; menu_INSTALL_AIMGR  ;;
    12 ) clear ; menu_INSTALL_EVTMGR  ;;
    21 ) clear ; menu_INSTALL_TURBO  ;;
    22 ) clear ; menu_INSTALL_HUMIO  ;;
    23 ) clear ; menu_INSTALL_AWX  ;;
    24 ) clear ; menu_INSTALL_ISTIO  ;;
    25 ) clear ; menu_INSTALL_ELK  ;;


    31 ) clear ; menu_INSTALL_AIOPSDEMO  ;;
    32 ) clear ; menu_INSTALL_LDAP  ;;
    33 ) clear ; menu_INSTALL_ROBOTSHOP  ;;

    41 ) clear ; menu_LOGIN_ARGO  ;;
    42 ) clear ; menu_APPS_ARGO  ;;

    0 ) clear ; exit ;;
    * ) clear ; incorrect_selection  ;;
  esac
  read -p "Press Enter to continue..."
  clear 
done


