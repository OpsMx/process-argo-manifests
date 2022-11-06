import sys
import re
import requests
import json
import logging
log = logging.getLogger()
log.setLevel(logging.INFO)
handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
log.addHandler(handler)

# Spinnaker gate webhook
API_ENDPOINT = 'https://isd.alpha.autopilot.opsmx.com/gate/webhooks/webhook/rapid7-main'

inFile = open('/tmp/tenents/sample-tenents', 'r')
lines = inFile.readlines()
tcount = 0                                    # Counter for tenents, for logging
global r # Declare response object so that it can be used outside of the try block  

# Get data for posting
def getTenentInfo(line):
    tName, args = cnfStr.split(":", 1)        # Get the 1st field, tenent
    print("Processing Tenent:" + args)
    argsList = args.split(",")
    postData =dict()
    postData["enabled"] = argsList[0]
    postData["gitRepo"] = argsList[1]
    postData["gitPath"] = argsList[2]
    postData["params"] = ",".join(argsList[3:])
    return (tName,postData)

def waitForNext(r):
    # Method that will check status of all pipelines triggered and ensure that max N pipelines are executing at a time
    # Else wait for the currently triggered pipelines to complete before returning
    return

# Main routine: Process tenents one-by-one and post it to API-endpoint
for line in lines:
    cnfStr = re.sub("\s*#.*","",line).strip() # Remove comments
    if not cnfStr:                            # Skip blank lines
        continue;

    tcount += 1
    log.info ("Processing {}: {}".format(tcount, cnfStr))
    tName,postData = getTenentInfo(line)      # Get data in a dict
    
    try:
        r = requests.post(url = API_ENDPOINT, json = postData)
    except:
        exc_type, exc_value, exc_traceback = sys.exc_info()
        log.error ("Error Connecting:" + str(exc_value))
        exit(1)
    else:
        if r.status_code == 200:
            log.info ("   Received:" + str(r.json()))
            waitForNext(r)
        else:
            log.info ("   Received ERROR status: http " + str(r.status_code))
            continue;
exit(0)


################################ CUT PASTE STUFF ################
#file1 = open('kustomize-learning/sample-tenents', 'r')
    #print("Line{}: {}".format(count, cnfStr))
    #print(tName)
    #ac=0
    #for arg in argsList:
    #    ac += 1
    #    print("Arg{}: {}".format(ac,arg))
    #except requests.exceptions.HTTPError as errh:
    #    print ("Http Error:",errh)
    #except requests.exceptions.ConnectionError as errc:
    #except requests.exceptions.Timeout as errt:
    #    print ("Timeout Error:",errt)
    #except requests.exceptions.RequestException as err:
    #    print ("OOps: Something Else",err)
    #reqData = json.dumps(postData)
    #print("   Sending:" + reqData)
