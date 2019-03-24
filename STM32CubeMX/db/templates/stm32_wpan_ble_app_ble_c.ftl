[#ftl]
/* USER CODE BEGIN Header */
/**
 ******************************************************************************
  * File Name          : ${name}
  * Description        : Application file for BLE 
  *                      middleWare.
  ******************************************************************************
[@common.optinclude name=mxTmpFolder+"/license.tmp"/][#--include License text --]
  ******************************************************************************
  */
/* USER CODE END Header */

[#assign BLE_TRANSPARENT_MODE_UART = 0]
[#assign BLE_TRANSPARENT_MODE_VCP = 0]
[#assign BT_SIG_BEACON = 0]
[#assign BT_SIG_BLOOD_PRESSURE_SENSOR = 0]
[#assign BT_SIG_HEALTH_THERMOMETER_SENSOR = 0]
[#assign BT_SIG_HEART_RATE_SENSOR = 0]
[#assign CUSTOM_OTA = 0]
[#assign CUSTOM_P2P_CLIENT = 0]
[#assign CUSTOM_P2P_ROUTER = 0]
[#assign CUSTOM_P2P_SERVER = 0]
[#assign CUSTOM_TEMPLATE = 0]
[#assign FREERTOS_STATUS = 0]
[#assign BLE_APPLICATION_TYPE = "This text shouldn't appear"]
[#assign LOCAL_NAME_FORMATTED = "This text shouldn't appear"]
[#assign P2P_SERVER_NUMBER = ""]

[#list SWIPdatas as SWIP]
	[#if SWIP.defines??]
		[#list SWIP.defines as definition]
            [#if (definition.name == "BLE_TRANSPARENT_MODE_UART") && (definition.value == "Enabled")]
                [#assign BLE_TRANSPARENT_MODE_UART = 1]
            [/#if]
            [#if (definition.name == "BLE_TRANSPARENT_MODE_VCP") && (definition.value == "Enabled")]
                [#assign BLE_TRANSPARENT_MODE_VCP = 1]
            [/#if]
            [#if (definition.name == "BT_SIG_BEACON") && (definition.value == "Enabled")]
                [#assign BT_SIG_BEACON = 1]
            [/#if]
            [#if (definition.name == "BT_SIG_BLOOD_PRESSURE_SENSOR") && (definition.value == "Enabled")]
                [#assign BT_SIG_BLOOD_PRESSURE_SENSOR = 1]
            [/#if]
            [#if (definition.name == "BT_SIG_HEALTH_THERMOMETER_SENSOR") && (definition.value == "Enabled")]
                [#assign BT_SIG_HEALTH_THERMOMETER_SENSOR = 1]
            [/#if]
            [#if (definition.name == "BT_SIG_HEART_RATE_SENSOR") && (definition.value == "Enabled")]
                [#assign BT_SIG_HEART_RATE_SENSOR = 1]
            [/#if]
            [#if (definition.name == "CUSTOM_OTA") && (definition.value == "Enabled")]
                [#assign CUSTOM_OTA = 1]
            [/#if]
            [#if (definition.name == "CUSTOM_P2P_CLIENT") && (definition.value == "Enabled")]
                [#assign CUSTOM_P2P_CLIENT = 1]
            [/#if]
            [#if (definition.name == "CUSTOM_P2P_ROUTER") && (definition.value =="Enabled")]
                [#assign CUSTOM_P2P_ROUTER = 1]
            [/#if]
            [#if (definition.name == "CUSTOM_P2P_SERVER") && (definition.value == "Enabled")]
                [#assign CUSTOM_P2P_SERVER = 1]
            [/#if]
            [#if (definition.name == "CUSTOM_TEMPLATE") && (definition.value == "Enabled")]
                [#assign CUSTOM_TEMPLATE = 1]
            [/#if]
            [#if definition.name == "BLE_APPLICATION_TYPE"]
                [#assign BLE_APPLICATION_TYPE = definition.value]
            [/#if]
            [#if (definition.name == "FREERTOS_STATUS") && (definition.value == "1")]
                [#assign FREERTOS_STATUS = 1]
            [/#if]
            [#if definition.name == "LOCAL_NAME_FORMATTED"]
                [#assign LOCAL_NAME_FORMATTED = definition.value]
            [/#if]
            [#if definition.name == "P2P_SERVER_NUMBER"]
                [#assign P2P_SERVER_NUMBER = definition.value]
            [/#if]
        [/#list]
	[/#if]
[/#list]

/* Includes ------------------------------------------------------------------*/
#include "main.h"

#include "app_common.h"

#include "dbg_trace.h"
#include "ble.h"
#include "tl.h"
#include "app_ble.h"

#include "scheduler.h"
#include "shci.h"
#include "lpm.h"
#include "otp.h"
[#if  (BT_SIG_BEACON = 1)]
#include "eddystone_beacon.h"
#include "eddystone_uid_service.h"
#include "eddystone_url_service.h"
#include "eddystone_tlm_service.h"
#include "IBeacon_service.h"
#include "ibeacon.h"
[/#if]
[#if  (BT_SIG_BLOOD_PRESSURE_SENSOR = 1)]
#include "bls_app.h"
[/#if]
[#if  (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1)]
#include "dis_app.h"
[/#if]
[#if  (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1)]
#include "hts_app.h"
[/#if]
[#if  (BT_SIG_HEART_RATE_SENSOR = 1)]
#include "hrs_app.h"
[/#if]
[#if  (CUSTOM_P2P_SERVER = 1)]
#include "p2p_server_app.h"
[/#if]
[#if  (CUSTOM_TEMPLATE = 1)]
#include "template_server_app.h"
[/#if]

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/

[#if  (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) || (CUSTOM_P2P_SERVER = 1)]
/**
 * security parameters structure
 */ 
typedef struct _tSecurityParams
{
  /**
   * IO capability of the device
   */
  uint8_t ioCapability;

  /**
   * Authentication requirement of the device
   * Man In the Middle protection required?
   */
  uint8_t mitm_mode;

  /**
   * bonding mode of the device
   */
  uint8_t bonding_mode;

  /**
   * Flag to tell whether OOB data has
   * to be used during the pairing process
   */
  uint8_t OOB_Data_Present; 

  /**
   * OOB data to be used in the pairing process if
   * OOB_Data_Present is set to TRUE
   */
  uint8_t OOB_Data[16]; 

  /**
   * this variable indicates whether to use a fixed pin
   * during the pairing process or a passkey has to be
   * requested to the application during the pairing process
   * 0 implies use fixed pin and 1 implies request for passkey
   */
  uint8_t Use_Fixed_Pin; 

  /**
   * minimum encryption key size requirement
   */
  uint8_t encryptionKeySizeMin;

  /**
   * maximum encryption key size requirement
   */
  uint8_t encryptionKeySizeMax;

  /**
   * fixed pin to be used in the pairing process if
   * Use_Fixed_Pin is set to 1
   */
  uint32_t Fixed_Pin;

  /**
   * this flag indicates whether the host has to initiate
   * the security, wait for pairing or does not have any security
   * requirements.\n
   * 0x00 : no security required
   * 0x01 : host should initiate security by sending the slave security
   *        request command
   * 0x02 : host need not send the clave security request but it
   * has to wait for paiirng to complete before doing any other
   * processing
   */
  uint8_t initiateSecurity;
}tSecurityParams;

/**
 * global context
 * contains the variables common to all 
 * services
 */ 
typedef struct _tBLEProfileGlobalContext
{

  /**
   * security requirements of the host
   */ 
  tSecurityParams bleSecurityParam;

  /**
   * gap service handle
   */
  uint16_t gapServiceHandle;

  /**
   * device name characteristic handle
   */ 
  uint16_t devNameCharHandle;

  /**
   * appearance characteristic handle
   */ 
  uint16_t appearanceCharHandle;

  /**
   * connection handle of the current active connection
   * When not in connection, the handle is set to 0xFFFF
   */ 
  uint16_t connectionHandle;

  /**
   * length of the UUID list to be used while advertising
   */ 
  uint8_t advtServUUIDlen;

  /**
   * the UUID list to be used while advertising
   */ 
  uint8_t advtServUUID[100];

}BleGlobalContext_t;

typedef struct
{
  BleGlobalContext_t BleApplicationContext_legacy;
   APP_BLE_ConnStatus_t Device_Connection_Status;
   /**
   * ID of the Advertising Timeout
   */
   uint8_t Advertising_mgr_timer_Id;

[#if  (CUSTOM_P2P_SERVER = 1)]
  uint8_t SwitchOffGPIO_timer_Id;
[/#if]
}BleApplicationContext_t;
[/#if]
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private defines -----------------------------------------------------------*/
#define APPBLE_GAP_DEVICE_NAME_LENGTH 7
[#if  (BT_SIG_BEACON = 1)]
  /**
  * Boot Mode:    1 (OTA)
  * Sector Index: 6
  * Nb Sectors  : 1
  */
#define BOOT_MODE_AND_SECTOR                                            0x010601
#define APP_SECTORS                                                            7
#define DATA_SECTOR                                                            6
[/#if]
[#if  (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) || (CUSTOM_P2P_SERVER = 1)]
#define FAST_ADV_TIMEOUT               (30*1000*1000/CFG_TS_TICK_VAL) /**< 30s */
#define INITIAL_ADV_TIMEOUT            (60*1000*1000/CFG_TS_TICK_VAL) /**< 60s */
[/#if]

#define BD_ADDR_SIZE_LOCAL    6

/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
PLACE_IN_SECTION("MB_MEM1") ALIGN(4) static TL_CmdPacket_t BleCmdBuffer;

static const uint8_t M_bd_addr[BD_ADDR_SIZE_LOCAL] =
    {
        (uint8_t)((CFG_ADV_BD_ADDRESS & 0x0000000000FF)),
        (uint8_t)((CFG_ADV_BD_ADDRESS & 0x00000000FF00) >> 8),
        (uint8_t)((CFG_ADV_BD_ADDRESS & 0x000000FF0000) >> 16),
        (uint8_t)((CFG_ADV_BD_ADDRESS & 0x0000FF000000) >> 24),
        (uint8_t)((CFG_ADV_BD_ADDRESS & 0x00FF00000000) >> 32),
        (uint8_t)((CFG_ADV_BD_ADDRESS & 0xFF0000000000) >> 40)
    };

static uint8_t bd_addr_udn[BD_ADDR_SIZE_LOCAL];

/**
*   Identity root key used to derive LTK and CSRK 
*/
static const uint8_t BLE_CFG_IR_VALUE[16] = CFG_BLE_IRK;

/**
* Encryption root key used to derive LTK and CSRK
*/
static const uint8_t BLE_CFG_ER_VALUE[16] = CFG_BLE_ERK;

[#if  (BT_SIG_BEACON = 1)]
static uint8_t sector_type;
[/#if]
[#if  (BT_SIG_BEACON = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) || (CUSTOM_P2P_SERVER = 1)]
/**
 * These are the two tags used to manage a power failure during OTA
 * The MagicKeywordAdress shall be mapped @0x140 from start of the binary image
 * The MagicKeywordvalue is checked in the ble_ota application
 */
PLACE_IN_SECTION("TAG_OTA_END") const uint32_t MagicKeywordValue = 0x94448A29 ;
PLACE_IN_SECTION("TAG_OTA_START") const uint32_t MagicKeywordAddress = (uint32_t)&MagicKeywordValue;

[/#if]
[#if  (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) || (CUSTOM_P2P_SERVER = 1)]
PLACE_IN_SECTION("BLE_APP_CONTEXT") static BleApplicationContext_t BleApplicationContext;
PLACE_IN_SECTION("BLE_APP_CONTEXT") static uint16_t AdvIntervalMin, AdvIntervalMax;

[/#if]

[#if  (CUSTOM_P2P_SERVER = 1)]
P2PS_APP_ConnHandle_Not_evt_t handleNotification;

#if L2CAP_REQUEST_NEW_CONN_PARAM != 0
#define SIZE_TAB_CONN_INT            2
float tab_conn_interval[SIZE_TAB_CONN_INT] = {50, 1000} ; /* ms */
uint8_t index_con_int, mutex; 
#endif 

/**
 * Advertising Data
 */
#if (P2P_SERVER1 != 0)
static const char local_name[] = { AD_TYPE_COMPLETE_LOCAL_NAME[#if P2P_SERVER_NUMBER = "P2P_SERVER1"] ${LOCAL_NAME_FORMATTED}[#else], 'P', '2', 'P', 'S', 'R', 'V', '1'[/#if]};
uint8_t manuf_data[14] = {
    sizeof(manuf_data)-1, AD_TYPE_MANUFACTURER_SPECIFIC_DATA, 
    0x01/*SKD version */,
    CFG_DEV_ID_P2P_SERVER1 /* STM32WB - P2P Server 1*/,
    0x00 /* GROUP A Feature  */, 
    0x00 /* GROUP A Feature */,
    0x00 /* GROUP B Feature */,
    0x00 /* GROUP B Feature */,
    0x00, /* BLE MAC start -MSB */
    0x00,
    0x00,
    0x00,
    0x00,
    0x00, /* BLE MAC stop */
};
#endif
/**
 * Advertising Data
 */
#if (P2P_SERVER2 != 0)
static const char local_name[] = { AD_TYPE_COMPLETE_LOCAL_NAME[#if P2P_SERVER_NUMBER = "P2P_SERVER2"] ${LOCAL_NAME_FORMATTED}[#else], 'P', '2', 'P', 'S', 'R', 'V', '2'[/#if]};
uint8_t manuf_data[14] = {
    sizeof(manuf_data)-1, AD_TYPE_MANUFACTURER_SPECIFIC_DATA, 
    0x01/*SKD version */,
    CFG_DEV_ID_P2P_SERVER2 /* STM32WB - P2P Server 2*/,
    0x00 /* GROUP A Feature  */, 
    0x00 /* GROUP A Feature */,
    0x00 /* GROUP B Feature */,
    0x00 /* GROUP B Feature */,
    0x00, /* BLE MAC start -MSB */
    0x00,
    0x00,
    0x00,
    0x00,
    0x00, /* BLE MAC stop */
};

#endif

#if (P2P_SERVER3 != 0)
static const char local_name[] = { AD_TYPE_COMPLETE_LOCAL_NAME[#if P2P_SERVER_NUMBER = "P2P_SERVER3"] ${LOCAL_NAME_FORMATTED}[#else], 'P', '2', 'P', 'S', 'R', 'V', '3'[/#if]};
uint8_t manuf_data[14] = {
    sizeof(manuf_data)-1, AD_TYPE_MANUFACTURER_SPECIFIC_DATA, 
    0x01/*SKD version */,
    CFG_DEV_ID_P2P_SERVER3 /* STM32WB - P2P Server 3*/,
    0x00 /* GROUP A Feature  */, 
    0x00 /* GROUP A Feature */,
    0x00 /* GROUP B Feature */,
    0x00 /* GROUP B Feature */,
    0x00, /* BLE MAC start -MSB */
    0x00,
    0x00,
    0x00,
    0x00,
    0x00, /* BLE MAC stop */
};
#endif

#if (P2P_SERVER4 != 0)
static const char local_name[] = { AD_TYPE_COMPLETE_LOCAL_NAME[#if P2P_SERVER_NUMBER = "P2P_SERVER4"] ${LOCAL_NAME_FORMATTED}[#else], 'P', '2', 'P', 'S', 'R', 'V', '4'[/#if]};
uint8_t manuf_data[14] = {
    sizeof(manuf_data)-1, AD_TYPE_MANUFACTURER_SPECIFIC_DATA, 
    0x01/*SKD version */,
    CFG_DEV_ID_P2P_SERVER4 /* STM32WB - P2P Server 4*/,
    0x00 /* GROUP A Feature  */, 
    0x00 /* GROUP A Feature */,
    0x00 /* GROUP B Feature */,
    0x00 /* GROUP B Feature */,
    0x00, /* BLE MAC start -MSB */
    0x00,
    0x00,
    0x00,
    0x00,
    0x00, /* BLE MAC stop */
};
#endif

#if (P2P_SERVER5 != 0)
static const char local_name[] = { AD_TYPE_COMPLETE_LOCAL_NAME[#if P2P_SERVER_NUMBER = "P2P_SERVER5"] ${LOCAL_NAME_FORMATTED}[#else], 'P', '2', 'P', 'S', 'R', 'V', '5'[/#if]};
uint8_t manuf_data[14] = {
    sizeof(manuf_data)-1, AD_TYPE_MANUFACTURER_SPECIFIC_DATA, 
    0x01/*SKD version */,
    CFG_DEV_ID_P2P_SERVER5 /* STM32WB - P2P Server 5*/,
    0x00 /* GROUP A Feature  */, 
    0x00 /* GROUP A Feature */,
    0x00 /* GROUP B Feature */,
    0x00 /* GROUP B Feature */,
    0x00, /* BLE MAC start -MSB */
    0x00,
    0x00,
    0x00,
    0x00,
    0x00, /* BLE MAC stop */
};
#endif

#if (P2P_SERVER6 != 0)
static const char local_name[] = { AD_TYPE_COMPLETE_LOCAL_NAME[#if P2P_SERVER_NUMBER = "P2P_SERVER6"] ${LOCAL_NAME_FORMATTED}[#else], 'P', '2', 'P', 'S', 'R', 'V', '6'[/#if]};
uint8_t manuf_data[14] = {
    sizeof(manuf_data)-1, AD_TYPE_MANUFACTURER_SPECIFIC_DATA, 
    0x01/*SKD version */,
    CFG_DEV_ID_P2P_SERVER6 /* STM32WB - P2P Server 1*/,
    0x00 /* GROUP A Feature  */, 
    0x00 /* GROUP A Feature */,
    0x00 /* GROUP B Feature */,
    0x00 /* GROUP B Feature */,
    0x00, /* BLE MAC start -MSB */
    0x00,
    0x00,
    0x00,
    0x00,
    0x00, /* BLE MAC stop */
};
#endif
[#else]
[#if (BT_SIG_HEART_RATE_SENSOR = 1)]
static const char local_name[] = { AD_TYPE_COMPLETE_LOCAL_NAME ${LOCAL_NAME_FORMATTED}};
uint8_t  manuf_data[14] = {
    sizeof(manuf_data)-1, AD_TYPE_MANUFACTURER_SPECIFIC_DATA,
    0x01/*SKD version */,
    0x00 /* Generic*/,
    0x00 /* GROUP A Feature  */, 
    0x00 /* GROUP A Feature */,
    0x00 /* GROUP B Feature */,
    0x00 /* GROUP B Feature */,
    0x00, /* BLE MAC start -MSB */
    0x00,
    0x00,
    0x00,
    0x00,
    0x00, /* BLE MAC stop */

};
[#else]
[#if  (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1)]
static const char local_name[] = {AD_TYPE_COMPLETE_LOCAL_NAME ${LOCAL_NAME_FORMATTED}};
[/#if]
[/#if]
[/#if]
/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
static void BLE_UserEvtRx( void * pPayload );
static void BLE_StatusNot( HCI_TL_CmdStatus_t status );
static void Ble_Tl_Init( void );
static void Ble_Hci_Gap_Gatt_Init(void);
static const uint8_t* BleGetBdAddress( void );
[#if  (BT_SIG_BEACON = 1)]
static void Beacon_Update( void );
[/#if]
[#if  (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) || (CUSTOM_P2P_SERVER = 1)]
static void Adv_Request( APP_BLE_ConnStatus_t New_Status );
[/#if]
[#if  (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1)]
static void Add_Advertisment_Service_UUID( uint16_t servUUID );
static void Adv_Mgr( void );
static void Adv_Update( void );
[/#if]
[#if  (CUSTOM_P2P_SERVER = 1)]
static void Adv_Cancel( void );
static void Adv_Cancel_Req( void );
static void Switch_OFF_GPIO( void );
#if(L2CAP_REQUEST_NEW_CONN_PARAM != 0)  
static void BLE_SVC_L2CAP_Conn_Update(uint16_t Connection_Handle);
#endif
[/#if]

/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Functions Definition ------------------------------------------------------*/
void APP_BLE_Init( void )
{
/* USER CODE BEGIN APP_BLE_Init_1 */

/* USER CODE END APP_BLE_Init_1 */
  SHCI_C2_Ble_Init_Cmd_Packet_t ble_init_cmd_packet =
  {
    {{0,0,0}},                          /**< Header unused */
    {0,                                 /** pBleBufferAddress not used */
    0,                                  /** BleBufferSize not used */
    CFG_BLE_NUM_GATT_ATTRIBUTES,
    CFG_BLE_NUM_GATT_SERVICES,
    CFG_BLE_ATT_VALUE_ARRAY_SIZE,
    CFG_BLE_NUM_LINK,
    CFG_BLE_DATA_LENGTH_EXTENSION,
    CFG_BLE_PREPARE_WRITE_LIST_SIZE,
    CFG_BLE_MBLOCK_COUNT,
    CFG_BLE_MAX_ATT_MTU,
    CFG_BLE_SLAVE_SCA,
    CFG_BLE_MASTER_SCA,
    CFG_BLE_LSE_SOURCE,
    CFG_BLE_MAX_CONN_EVENT_LENGTH,
    CFG_BLE_HSE_STARTUP_TIME,
    CFG_BLE_VITERBI_MODE,
    CFG_BLE_LL_ONLY,
    0}                                  /** TODO Should be read from HW */
  };

  /**
   * Initialize Ble Transport Layer
   */
  Ble_Tl_Init( );

  /**
   * Do not allow standby in the application
   */
  LPM_SetOffMode(1 << CFG_LPM_APP_BLE, LPM_OffMode_Dis);

  /**
   * Register the hci transport layer to handle BLE User Asynchronous Events
   */
  SCH_RegTask(CFG_TASK_HCI_ASYNCH_EVT_ID, hci_user_evt_proc);

  /**
   * Starts the BLE Stack on CPU2
   */
  SHCI_C2_BLE_Init( &ble_init_cmd_packet );

  /**
   * Initialization of HCI & GATT & GAP layer
   */
  Ble_Hci_Gap_Gatt_Init();

  /**
   * Initialization of the BLE Services
   */
  SVCCTL_Init();



[#if  (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) || (CUSTOM_P2P_SERVER = 1)]
  /**
   * Initialization of the BLE App Context
   */
[#if  (FREERTOS_STATUS = 0)]
  BleApplicationContext.Device_Connection_Status = APP_BLE_IDLE;
  BleApplicationContext.BleApplicationContext_legacy.connectionHandle = 0xFFFF;  
[#else]
  for (index = 0; index < CFG_MAX_CONNECTION; index++)
  {
    BleApplicationContext.Device_Connection_Status[index] = HR_IDLE;
    BleApplicationContext.BleApplicationContext_legacy.connectionHandle[index] = 0xFFFF;
  }
[/#if]  
[/#if]
  /**
   * From here, all initialization are BLE application specific
   */
[#if  (FREERTOS_STATUS = 0)]
[#if  (BT_SIG_BEACON = 1)]
  SCH_RegTask(CFG_TASK_BEACON_UPDATE_REQ_ID, Beacon_Update);
[/#if]
[#if  (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1)]
  SCH_RegTask(CFG_TASK_ADV_UPDATE_ID, Adv_Update);
[/#if]
[#if  (CUSTOM_P2P_SERVER = 1)]
  SCH_RegTask(CFG_TASK_ADV_CANCEL_ID, Adv_Cancel);
[/#if]
[#if  (BT_SIG_HEART_RATE_SENSOR = 1) || (CUSTOM_P2P_SERVER = 1)]
  /**
   * Initialization of ADV - Ad Manufacturer Element - Support OTA Bit Mask
   */
#if(BLE_CFG_OTA_REBOOT_CHAR != 0)  
    manuf_data[sizeof(manuf_data)-8] = CFG_FEATURE_OTA_REBOOT;
#endif
[/#if]
[#if  (CUSTOM_P2P_SERVER = 1)]
#if(RADIO_ACTIVITY_EVENT != 0)  
  aci_hal_set_radio_activity_mask(0x0006);
#endif  
  
#if (L2CAP_REQUEST_NEW_CONN_PARAM != 0 )
  index_con_int = 0; 
  mutex = 1; 
#endif
[/#if]
[/#if]
[#if  (BT_SIG_BLOOD_PRESSURE_SENSOR = 1)]
  /**
   * Initialize Blood Pressure Service
   */
  BLSAPP_Init();

[/#if]
[#if  (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1)]
  /**
   * Initialize DIS Application
   */
  DISAPP_Init();

[/#if]
[#if  (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1)]
  /**
   * Initialize HTS Application
   */
  HTSAPP_Init();

[/#if]
[#if  (BT_SIG_HEART_RATE_SENSOR = 1)]
  /**
   * Initialize HRS Application
   */
  HRSAPP_Init();

[/#if]
[#if  (CUSTOM_P2P_SERVER = 1)]
  /**
   * Initialize P2P Server Application
   */
  P2PS_APP_Init();

[/#if]
[#if  (CUSTOM_TEMPLATE = 1)]
  /**
   * Initialize Custom Server Application
   */
  TEMPLATE_APP_Init();
  
[/#if]

[#if  (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1)]
  /**
   * Create timer to handle the connection state machine
   */

  HW_TS_Create(CFG_TIM_PROC_ID_ISR, &(BleApplicationContext.Advertising_mgr_timer_Id), hw_ts_SingleShot, Adv_Mgr);

[/#if]
[#if  (CUSTOM_P2P_SERVER = 1)]
  /**
   * Create timer to handle the Advertising Stop
   */
  HW_TS_Create(CFG_TIM_PROC_ID_ISR, &(BleApplicationContext.Advertising_mgr_timer_Id), hw_ts_SingleShot, Adv_Cancel_Req);
  /**
   * Create timer to handle the Led Switch OFF
   */
  HW_TS_Create(CFG_TIM_PROC_ID_ISR, &(BleApplicationContext.SwitchOffGPIO_timer_Id), hw_ts_SingleShot, Switch_OFF_GPIO);

[/#if]
  /**
   * Make device discoverable
   */
[#if  (BT_SIG_BEACON = 1)]
  if (CFG_BEACON_TYPE & CFG_EDDYSTONE_UID_BEACON_TYPE)
  {
#if(CFG_DEBUG_APP_TRACE != 0)
    APP_DBG_MSG("Eddystone UID beacon advertize\n");
#endif
    EddystoneUID_Process();
  }
  else if (CFG_BEACON_TYPE & CFG_EDDYSTONE_URL_BEACON_TYPE)
  {
#if(CFG_DEBUG_APP_TRACE != 0)
    APP_DBG_MSG("Eddystone URL beacon advertize\n");
#endif
    EddystoneURL_Process();
  }
  else if (CFG_BEACON_TYPE & CFG_EDDYSTONE_TLM_BEACON_TYPE)
  {
#if(CFG_DEBUG_APP_TRACE != 0)
    APP_DBG_MSG("Eddystone TLM beacon advertize\n");
#endif
    EddystoneTLM_Process();
  }
  else if (CFG_BEACON_TYPE & CFG_IBEACON)
  {
#if(CFG_DEBUG_APP_TRACE != 0)
    APP_DBG_MSG("Ibeacon advertize\n");
#endif
    IBeacon_Process();
  }
[/#if]   
[#if  (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1)]
  BleApplicationContext.BleApplicationContext_legacy.advtServUUID[0] = AD_TYPE_16_BIT_SERV_UUID;
  BleApplicationContext.BleApplicationContext_legacy.advtServUUIDlen = 1;
[/#if]
[#if  (CUSTOM_P2P_SERVER = 1)]
  BleApplicationContext.BleApplicationContext_legacy.advtServUUID[0] = NULL;
  BleApplicationContext.BleApplicationContext_legacy.advtServUUIDlen = 0;
[/#if]
[#if  (BT_SIG_BLOOD_PRESSURE_SENSOR = 1)]
  Add_Advertisment_Service_UUID(BLOOD_PRESSURE_SERVICE_UUID);
[/#if]
[#if  (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1)]
  Add_Advertisment_Service_UUID(HEALTH_THERMOMETER_SERVICE_UUID);
[/#if]
[#if  (BT_SIG_HEART_RATE_SENSOR = 1)]
  Add_Advertisment_Service_UUID(HEART_RATE_SERVICE_UUID);
[/#if]
[#if  (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) || (CUSTOM_P2P_SERVER = 1)] 
  /* Initialize intervals for reconnexion without intervals update */
  AdvIntervalMin = CFG_FAST_CONN_ADV_INTERVAL_MIN;
  AdvIntervalMax = CFG_FAST_CONN_ADV_INTERVAL_MAX;

[#if (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1)] 
  /**
  * Start to Advertise to be connected by Collector
   */
[/#if]
[#if  (CUSTOM_P2P_SERVER = 1)] 
  /**
   * Start to Advertise to be connected by P2P Client
   */
[/#if]
   Adv_Request(APP_BLE_FAST_ADV);

[/#if]
/* USER CODE BEGIN APP_BLE_Init_2 */

/* USER CODE END APP_BLE_Init_2 */
  return;
}


SVCCTL_UserEvtFlowStatus_t SVCCTL_App_Notification( void *pckt )
{
  hci_event_pckt *event_pckt;
  evt_le_meta_event *meta_evt;
  evt_blue_aci *blue_evt;

  event_pckt = (hci_event_pckt*) ((hci_uart_pckt *) pckt)->data;

  switch (event_pckt->evt)
  {
    case EVT_DISCONN_COMPLETE:
[#if  (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) ||(CUSTOM_P2P_SERVER = 1)] 
    {
      hci_disconnection_complete_event_rp0 *disconnection_complete_event;
      disconnection_complete_event = (hci_disconnection_complete_event_rp0 *) event_pckt->data;

      if (disconnection_complete_event->Connection_Handle == BleApplicationContext.BleApplicationContext_legacy.connectionHandle)
      {
        BleApplicationContext.BleApplicationContext_legacy.connectionHandle = 0;
        BleApplicationContext.Device_Connection_Status = APP_BLE_IDLE;
#if(CFG_DEBUG_APP_TRACE != 0)
        APP_DBG_MSG("\r\n\r** DISCONNECTION EVENT WITH CLIENT \n");
#endif        
      }

      /* restart advertising */
      Adv_Request(APP_BLE_FAST_ADV);
[#if  (CUSTOM_P2P_SERVER = 1)] 
 /*
* SPECIFIC to P2P Server APP
*/     
        handleNotification.P2P_Evt_Opcode = PEER_DISCON_HANDLE_EVT;
        handleNotification.ConnectionHandle = BleApplicationContext.BleApplicationContext_legacy.connectionHandle;
        P2PS_APP_Notification(&handleNotification);

[/#if]
}
[/#if]

    break; /* EVT_DISCONN_COMPLETE */

    case EVT_LE_META_EVENT:
[#if (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) ||(CUSTOM_P2P_SERVER = 1)]
    {
[/#if]
      meta_evt = (evt_le_meta_event*) event_pckt->data;
      /* USER CODE BEGIN EVT_LE_META_EVENT */

      /* USER CODE END EVT_LE_META_EVENT */
      switch (meta_evt->subevent)
      {
[#if (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) ||(CUSTOM_P2P_SERVER = 1)]
        case EVT_LE_CONN_UPDATE_COMPLETE: 
#if(CFG_DEBUG_APP_TRACE != 0)
          APP_DBG_MSG("\r\n\r** CONNECTION UPDATE EVENT WITH CLIENT \n");
#endif
          /* USER CODE BEGIN EVT_LE_CONN_UPDATE_COMPLETE */

          /* USER CODE END EVT_LE_CONN_UPDATE_COMPLETE */
          break;
[/#if]
        case EVT_LE_CONN_COMPLETE:
[#if (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) ||(CUSTOM_P2P_SERVER = 1)]
          {
          hci_le_connection_complete_event_rp0 *connection_complete_event;

          /**
           * The connection is done, there is no need anymore to schedule the LP ADV
           */
          connection_complete_event = (hci_le_connection_complete_event_rp0 *) meta_evt->data;
          
          HW_TS_Stop(BleApplicationContext.Advertising_mgr_timer_Id);

#if(CFG_DEBUG_APP_TRACE != 0)
          APP_DBG_MSG("EVT_LE_CONN_COMPLETE for connection handle 0x%x\n",
          connection_complete_event->Connection_Handle);
#endif
            if (BleApplicationContext.Device_Connection_Status == APP_BLE_LP_CONNECTING)
            {
              /* Connection as client */
              BleApplicationContext.Device_Connection_Status = APP_BLE_CONNECTED_CLIENT;
            }
            else
            {
              /* Connection as server */
              BleApplicationContext.Device_Connection_Status = APP_BLE_CONNECTED_SERVER;
            }
            BleApplicationContext.BleApplicationContext_legacy.connectionHandle =
                connection_complete_event->Connection_Handle;
[#if  (CUSTOM_P2P_SERVER = 1)] 
 /*
* SPECIFIC to P2P Server APP
*/             
          handleNotification.P2P_Evt_Opcode = PEER_CONN_HANDLE_EVT;
          handleNotification.ConnectionHandle = BleApplicationContext.BleApplicationContext_legacy.connectionHandle;
          P2PS_APP_Notification(&handleNotification);
[/#if]
          /* USER CODE BEGIN HCI_EVT_LE_CONN_COMPLETE */

          /* USER CODE END HCI_EVT_LE_CONN_COMPLETE */
          }
[/#if]
        break; /* HCI_EVT_LE_CONN_COMPLETE */

        default:
          /* USER CODE BEGIN SUBEVENT_DEFAULT */

          /* USER CODE END SUBEVENT_DEFAULT */
          break;
[#if (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) ||(CUSTOM_P2P_SERVER = 1)]
      }
[/#if]
    }
    break; /* HCI_EVT_LE_META_EVENT */

    case EVT_VENDOR:
      blue_evt = (evt_blue_aci*) event_pckt->data;
      /* USER CODE BEGIN EVT_VENDOR */

      /* USER CODE END EVT_VENDOR */
      switch (blue_evt->ecode)
      {
      /* USER CODE BEGIN ecode */

      /* USER CODE END ecode */
[#if (CUSTOM_P2P_SERVER = 1)]
/*
* SPECIFIC to P2P Server APP
*/
        case EVT_BLUE_L2CAP_CONNECTION_UPDATE_RESP:
#if (L2CAP_REQUEST_NEW_CONN_PARAM != 0 )
          mutex = 1;
#endif
      /* USER CODE BEGIN EVT_BLUE_L2CAP_CONNECTION_UPDATE_RESP */

      /* USER CODE END EVT_BLUE_L2CAP_CONNECTION_UPDATE_RESP */
      break;
[/#if]
        case EVT_BLUE_GAP_PROCEDURE_COMPLETE:
[#if (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) ||(CUSTOM_P2P_SERVER = 1)]
#if(CFG_DEBUG_APP_TRACE != 0)
        APP_DBG_MSG("\r\n\r** EVT_BLUE_GAP_PROCEDURE_COMPLETE \n");
#endif
[/#if]
        /* USER CODE BEGIN EVT_BLUE_GAP_PROCEDURE_COMPLETE */

        /* USER CODE END EVT_BLUE_GAP_PROCEDURE_COMPLETE */
        break; /* EVT_BLUE_GAP_PROCEDURE_COMPLETE */
[#if (CUSTOM_P2P_SERVER = 1)]
#if(RADIO_ACTIVITY_EVENT != 0)
        case 0x0004:
        /* USER CODE BEGIN RADIO_ACTIVITY_EVENT*/

        /* USER CODE END RADIO_ACTIVITY_EVENT*/
        break; /* RADIO_ACTIVITY_EVENT */
#endif
[/#if]
      }
      break; /* EVT_VENDOR */

        default:
        /* USER CODE BEGIN ECODE_DEFAULT*/

        /* USER CODE END ECODE_DEFAULT*/
          break;
  }

  return (SVCCTL_UserEvtFlowEnable);
}

[#if (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) ||(CUSTOM_P2P_SERVER = 1)]
APP_BLE_ConnStatus_t APP_BLE_Get_Server_Connection_Status(void)
{
    return BleApplicationContext.Device_Connection_Status;
}
[/#if]

/* USER CODE BEGIN FD*/

/* USER CODE END FD*/
/*************************************************************
 *
 * LOCAL FUNCTIONS
 *
 *************************************************************/
static void Ble_Tl_Init( void )
{
  HCI_TL_HciInitConf_t Hci_Tl_Init_Conf;

  Hci_Tl_Init_Conf.p_cmdbuffer = (uint8_t*)&BleCmdBuffer;
  Hci_Tl_Init_Conf.StatusNotCallBack = BLE_StatusNot;
  hci_init(BLE_UserEvtRx, (void*) &Hci_Tl_Init_Conf);

  return;
}

 static void Ble_Hci_Gap_Gatt_Init(void){

  uint8_t role;
[#if (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) ||(CUSTOM_P2P_SERVER = 1)]
  uint8_t index;
[/#if]
  uint16_t gap_service_handle, gap_dev_name_char_handle, gap_appearance_char_handle;
  const uint8_t *bd_addr;
  uint32_t srd_bd_addr[2];
  uint16_t appearance[1] = { BLE_CFG_GAP_APPEARANCE }; 

  /**
   * Initialize HCI layer
   */
  /*HCI Reset to synchronise BLE Stack*/
  hci_reset();

  /**
   * Write the BD Address
   */

  bd_addr = BleGetBdAddress();
  aci_hal_write_config_data(CONFIG_DATA_PUBADDR_OFFSET,
                            CONFIG_DATA_PUBADDR_LEN,
                            (uint8_t*) bd_addr);

[#if (BT_SIG_BEACON = 1) || (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1)]
  /**
   * Static random Address
   * The two upper bits shall be set to 1
   * The lowest 32bits is read from the UDN to differentiate between devices
   * The RNG may be used to provide a random number on each power on
   */
  srd_bd_addr[1] =  0x0000ED6E;
  srd_bd_addr[0] =  LL_FLASH_GetUDN( );
  aci_hal_write_config_data( CONFIG_DATA_RANDOM_ADDRESS_OFFSET, CONFIG_DATA_RANDOM_ADDRESS_LEN, (uint8_t*)srd_bd_addr );
  
[/#if]                        
[#if (BT_SIG_HEART_RATE_SENSOR = 1) || (CUSTOM_P2P_SERVER = 1)]                        
  /* BLE MAC in ADV Packet */
  manuf_data[ sizeof(manuf_data)-6] = bd_addr[5];
  manuf_data[ sizeof(manuf_data)-5] = bd_addr[4];
  manuf_data[ sizeof(manuf_data)-4] = bd_addr[3];
  manuf_data[ sizeof(manuf_data)-3] = bd_addr[2];
  manuf_data[ sizeof(manuf_data)-2] = bd_addr[1];
  manuf_data[ sizeof(manuf_data)-1] = bd_addr[0];
  
[#if (BT_SIG_HEART_RATE_SENSOR = 1)]
  /**
   * Write Identity root key used to derive LTK and CSRK 
   */
    aci_hal_write_config_data(CONFIG_DATA_IR_OFFSET,
    CONFIG_DATA_IR_LEN,
                            (uint8_t*) BLE_CFG_IR_VALUE);
    
   /**
   * Write Encryption root key used to derive LTK and CSRK
   */
    aci_hal_write_config_data(CONFIG_DATA_ER_OFFSET,
    CONFIG_DATA_ER_LEN,
                            (uint8_t*) BLE_CFG_ER_VALUE);

   /**
   * Write random bd_address
   */
   /* random_bd_address = R_bd_address;
    aci_hal_write_config_data(CONFIG_DATA_RANDOM_ADDRESS_WR,
    CONFIG_DATA_RANDOM_ADDRESS_LEN,
                            (uint8_t*) random_bd_address);
  */

[/#if]
  /**
   * Static random Address
   * The two upper bits shall be set to 1
   * The lowest 32bits is read from the UDN to differentiate between devices
   * The RNG may be used to provide a random number on each power on
   */
  srd_bd_addr[1] =  0x0000ED6E;
  srd_bd_addr[0] =  LL_FLASH_GetUDN( );
  aci_hal_write_config_data( CONFIG_DATA_RANDOM_ADDRESS_OFFSET, CONFIG_DATA_RANDOM_ADDRESS_LEN, (uint8_t*)srd_bd_addr );

[/#if]
  /**
   * Write Identity root key used to derive LTK and CSRK 
   */
    aci_hal_write_config_data( CONFIG_DATA_IR_OFFSET, CONFIG_DATA_IR_LEN, (uint8_t*)BLE_CFG_IR_VALUE );
    
   /**
   * Write Encryption root key used to derive LTK and CSRK
   */
    aci_hal_write_config_data( CONFIG_DATA_ER_OFFSET, CONFIG_DATA_ER_LEN, (uint8_t*)BLE_CFG_ER_VALUE );

  /**
   * Set TX Power to 0dBm.
   */
  aci_hal_set_tx_power_level(1, CFG_TX_POWER);

  /**
   * Initialize GATT interface
   */
  aci_gatt_init();

  /**
   * Initialize GAP interface
   */
  role = 0;

#if (BLE_CFG_PERIPHERAL == 1)
  role |= GAP_PERIPHERAL_ROLE;
#endif

#if (BLE_CFG_CENTRAL == 1)
  role |= GAP_CENTRAL_ROLE;
#endif

  if (role > 0)
  {
[#if (BT_SIG_HEART_RATE_SENSOR = 1) || (CUSTOM_P2P_SERVER = 1)]
    const char *name = "STM32WB";
[#else]
    const char *name = "BLEcore";
[/#if]
    aci_gap_init(role, 0,
                 APPBLE_GAP_DEVICE_NAME_LENGTH,
                 &gap_service_handle, &gap_dev_name_char_handle, &gap_appearance_char_handle);

    if (aci_gatt_update_char_value(gap_service_handle, gap_dev_name_char_handle, 0, strlen(name), (uint8_t *) name))
    {
      BLE_DBG_SVCCTL_MSG("Device Name aci_gatt_update_char_value failed.\n");
    }
  }

  if(aci_gatt_update_char_value(gap_service_handle,
                                gap_appearance_char_handle,
                                0,
                                2,
                                (uint8_t *)&appearance))
  {
    BLE_DBG_SVCCTL_MSG("Appearance aci_gatt_update_char_value failed.\n");
  }
[#if (BT_SIG_HEART_RATE_SENSOR = 1) || (CUSTOM_P2P_SERVER = 1)]
/**
   * Initialize Default PHY
   */
  hci_le_set_default_phy(ALL_PHYS_PREFERENCE,TX_2M_PREFERRED,RX_2M_PREFERRED); 

[/#if]
[#if (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) ||(CUSTOM_P2P_SERVER = 1)]
  /**
   * Initialize IO capability
   */
  BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.ioCapability = CFG_IO_CAPABILITY;
  aci_gap_set_io_capability(BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.ioCapability);

  /**
   * Initialize authentication
   */
  BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.mitm_mode = CFG_MITM_PROTECTION;
  BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.OOB_Data_Present = 0;
  BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.encryptionKeySizeMin = 8;
  BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.encryptionKeySizeMax = 16;
  BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.Use_Fixed_Pin = 0;
  BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.Fixed_Pin = 111111;
  BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.bonding_mode = 1;
  for (index = 0; index < 16; index++)
  {
    BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.OOB_Data[index] = (uint8_t) index;
  }

  aci_gap_set_authentication_requirement(BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.bonding_mode,
                                         BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.mitm_mode,
                                         0,
                                         0,
                                         BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.encryptionKeySizeMin,
                                         BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.encryptionKeySizeMax,
                                         BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.Use_Fixed_Pin,
                                         BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.Fixed_Pin,
0
  );

  /**
   * Initialize whitelist
   */
   if (BleApplicationContext.BleApplicationContext_legacy.bleSecurityParam.bonding_mode)
   {
     aci_gap_configure_whitelist();
   }
[/#if]
}
[#if (BT_SIG_BEACON = 1)]
static void Beacon_Update( void )
{
  FLASH_EraseInitTypeDef erase;
  uint32_t pageError = 0;

  if(sector_type != 0)
  {
    erase.TypeErase = FLASH_TYPEERASE_PAGES;
    erase.Page      = sector_type;
    if(sector_type == APP_SECTORS)
    {
      erase.NbPages = 2;  /* 2 sectors for beacon application */
    }
    else
    {
      erase.NbPages = 1; /* 1 sector for beacon user data */
    }
    
    HAL_FLASH_Unlock();
    __HAL_FLASH_CLEAR_FLAG(FLASH_FLAG_EOP | FLASH_FLAG_WRPERR | FLASH_FLAG_OPTVERR);
    
    HAL_FLASHEx_Erase(&erase, &pageError);
    
    HAL_FLASH_Lock();
  }
  
  *(uint32_t*) SRAM1_BASE = BOOT_MODE_AND_SECTOR; 
  /**
   * Boot Mode:    1 (OTA)
   * Sector Index: 6
   * Nb Sectors  : 1
   */
  NVIC_SystemReset();

  return;
}

[/#if]




[#if (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) ||(CUSTOM_P2P_SERVER = 1)]
static void Adv_Request(APP_BLE_ConnStatus_t New_Status)
{
  tBleStatus ret = BLE_STATUS_INVALID_PARAMS;
  uint16_t Min_Inter, Max_Inter;
 
  if (New_Status == APP_BLE_FAST_ADV)
  {
    Min_Inter = AdvIntervalMin;
    Max_Inter = AdvIntervalMax;
  }
  else
  {
    Min_Inter = CFG_LP_CONN_ADV_INTERVAL_MIN;
    Max_Inter = CFG_LP_CONN_ADV_INTERVAL_MAX;
  }


    /**
     * Stop the timer, it will be restarted for a new shot
     * It does not hurt if the timer was not running
     */
    HW_TS_Stop(BleApplicationContext.Advertising_mgr_timer_Id);

#if(CFG_DEBUG_APP_TRACE != 0)
    APP_DBG_MSG("First index in %d state \n",
    BleApplicationContext.Device_Connection_Status);
#endif
    if ((New_Status == APP_BLE_LP_ADV)
        && ((BleApplicationContext.Device_Connection_Status == APP_BLE_FAST_ADV)
            || (BleApplicationContext.Device_Connection_Status == APP_BLE_LP_ADV)))
    {
      /* Connection in ADVERTISE mode have to stop the current advertising */
      ret = aci_gap_set_non_discoverable();
      if (ret == BLE_STATUS_SUCCESS)
      {
#if(CFG_DEBUG_APP_TRACE != 0)
        APP_DBG_MSG("Successfully Stopped Advertising");
#endif
        }
      else
      {
#if(CFG_DEBUG_APP_TRACE != 0)
        APP_DBG_MSG("Stop Advertising Failed , result: %d \n", ret);
#endif
        }
    }

    BleApplicationContext.Device_Connection_Status = New_Status;
    /* Start Fast or Low Power Advertising */
    ret = aci_gap_set_discoverable(
        ADV_IND,
        Min_Inter,
        Max_Inter,
        PUBLIC_ADDR,
        NO_WHITE_LIST_USE, /* use white list */
        sizeof(local_name),
        (uint8_t*) &local_name,
        BleApplicationContext.BleApplicationContext_legacy.advtServUUIDlen,
        BleApplicationContext.BleApplicationContext_legacy.advtServUUID,
        0,
        0);
[#if (BT_SIG_HEART_RATE_SENSOR = 1) ||(CUSTOM_P2P_SERVER = 1)]   
    /* Update Advertising data */
    ret = aci_gap_update_adv_data(sizeof(manuf_data), (uint8_t*) manuf_data);

[/#if]
     if (ret == BLE_STATUS_SUCCESS)
    {
      if (New_Status == APP_BLE_FAST_ADV)
      {
        APP_DBG_MSG("Successfully Start Fast Advertising " );
        /* Start Timer to STOP ADV - TIMEOUT */
        HW_TS_Start(BleApplicationContext.Advertising_mgr_timer_Id, INITIAL_ADV_TIMEOUT);
      }
      else
      {
#if(CFG_DEBUG_APP_TRACE != 0)
        APP_DBG_MSG("Successfully Start Low Power Advertising ");
#endif
        }
    }
    else
    {
      if (New_Status == APP_BLE_FAST_ADV)
      {
#if(CFG_DEBUG_APP_TRACE != 0)
        APP_DBG_MSG("Start Fast Advertising Failed , result: %d \n", ret);
#endif
      }
      else
      {
#if(CFG_DEBUG_APP_TRACE != 0)
        APP_DBG_MSG("Start Low Power Advertising Failed , result: %d \n", ret);
#endif
      }
    }

[/#if]

[#if (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1) ||(CUSTOM_P2P_SERVER = 1)]
  return;
}

[/#if]

const uint8_t* BleGetBdAddress( void )
{
  uint8_t *otp_addr;
  const uint8_t *bd_addr;
  uint32_t udn;
  uint32_t company_id;
  uint32_t device_id;

  udn = LL_FLASH_GetUDN();

  if(udn != 0xFFFFFFFF)
  {
    company_id = LL_FLASH_GetSTCompanyID();
    device_id = LL_FLASH_GetDeviceID();

    bd_addr_udn[0] = (uint8_t)(udn & 0x000000FF);
    bd_addr_udn[1] = (uint8_t)( (udn & 0x0000FF00) >> 8 );
    bd_addr_udn[2] = (uint8_t)( (udn & 0x00FF0000) >> 16 );
    bd_addr_udn[3] = (uint8_t)device_id;
    bd_addr_udn[4] = (uint8_t)(company_id & 0x000000FF);;
    bd_addr_udn[5] = (uint8_t)( (company_id & 0x0000FF00) >> 8 );

    bd_addr = (const uint8_t *)bd_addr_udn;
  }
  else
  {
    otp_addr = OTP_Read(0);
    if(otp_addr)
    {
      bd_addr = ((OTP_ID0_t*)otp_addr)->bd_address;
    }
    else
    {
      bd_addr = M_bd_addr;
    }

  }

  return bd_addr;
}

/* USER CODE BEGIN FD_LOCAL_FUNCTION */

/* USER CODE END FD_LOCAL_FUNCTION */

[#if (BT_SIG_BLOOD_PRESSURE_SENSOR = 1) || (BT_SIG_HEALTH_THERMOMETER_SENSOR = 1) || (BT_SIG_HEART_RATE_SENSOR = 1)]

/*************************************************************
 *
 *SPECIFIC FUNCTIONS
 *
 *************************************************************/
static void Add_Advertisment_Service_UUID( uint16_t servUUID )
{
  BleApplicationContext.BleApplicationContext_legacy.advtServUUID[BleApplicationContext.BleApplicationContext_legacy.advtServUUIDlen] =
      (uint8_t) (servUUID & 0xFF);
  BleApplicationContext.BleApplicationContext_legacy.advtServUUIDlen++;
  BleApplicationContext.BleApplicationContext_legacy.advtServUUID[BleApplicationContext.BleApplicationContext_legacy.advtServUUIDlen] =
      (uint8_t) (servUUID >> 8) & 0xFF;
  BleApplicationContext.BleApplicationContext_legacy.advtServUUIDlen++;

  return;
}


static void Adv_Mgr( void )
{
  /**
   * The code shall be executed in the background as an aci command may be sent
   * The background is the only place where the application can make sure a new aci command
   * is not sent if there is a pending one
   */
  SCH_SetTask(1 << CFG_TASK_ADV_UPDATE_ID, CFG_SCH_PRIO_0);

  return;
}

static void Adv_Update( void )
{
  Adv_Request(APP_BLE_LP_ADV);

  return;
}

[/#if]
[#if (CUSTOM_P2P_SERVER = 1)]
/*************************************************************
 *
 *SPECIFIC FUNCTIONS FOR P2P SERVER
 *
 *************************************************************/
static void Adv_Cancel( void )
{
/* USER CODE BEGIN Adv_Cancel_1 */

/* USER CODE END Adv_Cancel_1 */

  if (BleApplicationContext.Device_Connection_Status != APP_BLE_CONNECTED_SERVER)

  {

    tBleStatus result = 0x00;

    result = aci_gap_set_non_discoverable();

    BleApplicationContext.Device_Connection_Status = APP_BLE_IDLE;
    if (result == BLE_STATUS_SUCCESS)
    {
#if(CFG_DEBUG_APP_TRACE != 0)
      APP_DBG_MSG("  \r\n\r");APP_DBG_MSG("** STOP ADVERTISING **  \r\n\r");
#endif
    }
    else
    {
#if(CFG_DEBUG_APP_TRACE != 0)
      APP_DBG_MSG("** STOP ADVERTISING **  Failed \r\n\r");
#endif
    }

  }

/* USER CODE BEGIN Adv_Cancel_2 */

/* USER CODE END Adv_Cancel_2 */
  return;
}

static void Adv_Cancel_Req( void )
{
/* USER CODE BEGIN Adv_Cancel_Req_1 */

/* USER CODE END Adv_Cancel_Req_1 */
  SCH_SetTask(1 << CFG_TASK_ADV_CANCEL_ID, CFG_SCH_PRIO_0);
/* USER CODE BEGIN Adv_Cancel_Req_2 */

/* USER CODE END Adv_Cancel_Req_2 */
  return;
}

static void Switch_OFF_GPIO(){
/* USER CODE BEGIN Switch_OFF_GPIO */

/* USER CODE END Switch_OFF_GPIO */
}


#if(L2CAP_REQUEST_NEW_CONN_PARAM != 0)  
void BLE_SVC_L2CAP_Conn_Update(uint16_t Connection_Handle)
{
/* USER CODE BEGIN BLE_SVC_L2CAP_Conn_Update_1 */

/* USER CODE END BLE_SVC_L2CAP_Conn_Update_1 */
  if(mutex == 1) { 
    mutex = 0;
    index_con_int = (index_con_int + 1)%SIZE_TAB_CONN_INT;
    uint16_t interval_min = CONN_P(tab_conn_interval[index_con_int]);
    uint16_t interval_max = CONN_P(tab_conn_interval[index_con_int]);
    uint16_t slave_latency = L2CAP_SLAVE_LATENCY;
    uint16_t timeout_multiplier = L2CAP_TIMEOUT_MULTIPLIER;
    tBleStatus result;


    result = aci_l2cap_connection_parameter_update_req(BleApplicationContext.BleApplicationContext_legacy.connectionHandle,
                                                       interval_min, interval_max,
                                                       slave_latency, timeout_multiplier);
    if( result == BLE_STATUS_SUCCESS )
    {
#if(CFG_DEBUG_APP_TRACE != 0)
      APP_DBG_MSG("BLE_SVC_L2CAP_Conn_Update(), Successfully \r\n\r");
#endif
    }
    else
    {
#if(CFG_DEBUG_APP_TRACE != 0)
      APP_DBG_MSG("BLE_SVC_L2CAP_Conn_Update(), Failed \r\n\r");
#endif
    }
  }
/* USER CODE BEGIN BLE_SVC_L2CAP_Conn_Update_2 */

/* USER CODE END BLE_SVC_L2CAP_Conn_Update_2 */
  return;
}
#endif
[/#if]

/* USER CODE BEGIN FD_SPECIFIC_FUNCTIONS */

/* USER CODE END FD_SPECIFIC_FUNCTIONS */
/*************************************************************
 *
 * WRAP FUNCTIONS
 *
 *************************************************************/
void hci_notify_asynch_evt(void* pdata)
{
  SCH_SetTask(1 << CFG_TASK_HCI_ASYNCH_EVT_ID, CFG_SCH_PRIO_0);
  return;
}

void hci_cmd_resp_release(uint32_t flag)
{
  SCH_SetEvt(1 << CFG_IDLEEVT_SYSTEM_HCI_CMD_EVT_RSP_ID);
  return;
}

void hci_cmd_resp_wait(uint32_t timeout)
{
  SCH_WaitEvt(1 << CFG_IDLEEVT_SYSTEM_HCI_CMD_EVT_RSP_ID);
  return;
}

static void BLE_UserEvtRx( void * pPayload )
{
  SVCCTL_UserEvtFlowStatus_t svctl_return_status;
  tHCI_UserEvtRxParam *pParam;

  pParam = (tHCI_UserEvtRxParam *)pPayload; 

  svctl_return_status = SVCCTL_UserEvtRx((void *)&(pParam->pckt->evtserial));
  if (svctl_return_status != SVCCTL_UserEvtFlowDisable)
  {
    pParam->status = HCI_TL_UserEventFlow_Enable;
  }
  else
  {
    pParam->status = HCI_TL_UserEventFlow_Disable;
  }
}

static void BLE_StatusNot( HCI_TL_CmdStatus_t status )
{
  uint32_t task_id_list;
  switch (status)
  {
    case HCI_TL_CmdBusy:
      /**
       * All tasks that may send an aci/hci commands shall be listed here
       * This is to prevent a new command is sent while one is already pending
       */
      task_id_list = (1 << CFG_LAST_TASK_ID_WITH_HCICMD) - 1;
      SCH_PauseTask(task_id_list);

      break;

    case HCI_TL_CmdAvailable:
      /**
       * All tasks that may send an aci/hci commands shall be listed here
       * This is to prevent a new command is sent while one is already pending
       */
      task_id_list = (1 << CFG_LAST_TASK_ID_WITH_HCICMD) - 1;
      SCH_ResumeTask(task_id_list);

      break;

    default:
      break;
  }
  return;
}

void SVCCTL_ResumeUserEventFlow( void )
{
  hci_resume_flow();
  return;
}


/* USER CODE BEGIN FD_WRAP_FUNCTIONS */

/* USER CODE END FD_WRAP_FUNCTIONS */
/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/