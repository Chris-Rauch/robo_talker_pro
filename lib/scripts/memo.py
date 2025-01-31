import os
import sys
import csv
import time
import json
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import StaleElementReferenceException
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException
#from third_eye_nav import ThirdEye


error_wait_time = 15

class ThirdEye:
    def __init__(self,headless,chromedriver_path):
        #create driver object and set it to the Third Eye home page
        chrome_options = webdriver.ChromeOptions()
        if headless == 'headless':
            chrome_options.add_argument('--headless')
        chrome_driver_path = chromedriver_path #path to chrome driver    
        #chrome_driver_path = "/Users/chris/Projects/GAAC/Return-Mail/chromedriver" #path to chrome driver
        self.driver = webdriver.Chrome(options=chrome_options)
        self.wait = WebDriverWait(self.driver,error_wait_time)
        self.driver.get("https://gaac.thirdeyesys.ca/insight/")
        
    def __del__(self):
        self.driver.quit()
        
    def login(self,username,password):
        try:
            #find login elements
            login_ID  = self.wait.until(EC.presence_of_element_located((By.NAME,"LoginId")))
            login_pwd = self.wait.until(EC.presence_of_element_located((By.NAME,"LoginPassword")))
            
            #self.driver.find_element_by_name("login").click() #click login button
        except TimeoutException:
            print("Timeout Error. Failed to login")
            return False
        except:
            print("Unknown Error Logging In")
            return False
        else:
            # send key strokes 
            login_ID.clear()
            login_pwd.clear()
            login_ID.send_keys(username)
            login_pwd.send_keys(password)
            self.wait.until(EC.presence_of_element_located((By.NAME,"login"))).click()
            
        # test for successful login
        try:
            self.wait.until(EC.presence_of_element_located((By.XPATH,"//*[contains(.,'Admin Options')]")))
        except TimeoutException:
            print("Unsuccessful Login")
            return False
        
        return True
    
    '''
    Description: Helps navigate to certain pages in Third Eye. For some moves, self.driver is expected to be ALREADY
        set to a certain page
    Input:  [dest] - The destination to be travelled to.
    Output: sets self.driver to the new page and returns true if successful. Otherwise, false
    '''      
    def navigate_to(self, dest):
        if dest == 'Search Page':
            try:
                #self.driver.get("https://gaac.thirdeyesys.ca/insight/ControllerServlet?action=423&guid=1587937407822")
                #self.driver.get("https://gaac.thirdeyesys.ca/insight/ControllerServlet?action=424&guid=1627782722626")
                #https://gaac.thirdeyesys.ca/insight/ControllerServlet?action=424&guid=1627782722626
                self.driver.get("https://gaac.thirdeyesys.ca/insight/ControllerServlet?action=425&guid=1715820258692")
            except:
                print("Failed to navigate to " + dest)
                return False
        
        elif dest == 'Memo Screen':
            #self.driver.find_element_by_xpath("//body").send_keys(Keys.ALT, 'M')
            
            try:
                self.wait.until(EC.presence_of_element_located((By.XPATH,"//body"))).send_keys(Keys.ALT, 'M')
                self.wait.until(EC.presence_of_element_located((By.ID,"memoFunctions"))).click()
            except TimeoutException:
                print("Failed To Navigate To Memo Screen... Driver must be on a contract page to so this")
                return False
        
        return True
           
    '''
    Description: Memo's accounts in Third Eye. Expected to already be on the 'Search Contracts' page
    Input:  [account_numbers] - list of account numbers. MWF prefix is optional {MWF99999,99999}              
            [memo_subject]    - The subject as a string
            [memo_body]       - The body as a string
            [insured_name]    - Optional. Used to do an additional check 
    Output: Returns true if all the accounts were memo'd succsesfully. Otherwise,
            return false.    
    '''
    def memo_account(self,account_number,memo_subject,memo_body,insured_name = None):
        
        #search for account and move to memo screen
        self.search_account(account_number)
        self.navigate_to('Memo Screen')
        
        #write memo
        try:
            memoSubject = self.wait.until(EC.presence_of_element_located((By.ID,"memoSubject")))
            memoBody    = self.wait.until(EC.presence_of_element_located((By.ID,"memoBody")))
            memoSubject.clear()
            memoBody.clear()
            memoSubject.send_keys(memo_subject)
            memoBody.send_keys(memo_body)
        except TimeoutException:
            print("Could not find the memo's subject line/body")
            return False
        except:
            print("Unknown Error")
            return False
        
        #save memo
        try:
            save_memo = self.wait.until(EC.presence_of_element_located((By.XPATH,'//*[@title="Save Memo"]')))
        except TimeoutException:
            print("Could not find 'save memo' button")
            return False
        except:
            print("Unknown Error")
            return False
        else:
            save_memo.click()
            #print("Save succussful")
            return True
        
    '''
    Description:
    In:
    Out:
    '''
    def search_account(self,account_number):
        #check for empty string
        if not account_number:
            return False
        #input contract number into search bar and search
        try:
            contractSearch = self.wait.until(EC.presence_of_element_located((By.NAME,"VISIBLE_ContractNo")))
            contractSearch.clear()
            contractSearch.send_keys(account_number)
            self.wait.until(EC.presence_of_element_located((By.NAME,"quoteSearchContractByAll"))).click()
        except TimeoutException:
            print("Could not find search bar")
            return False
        except:
            print("Unknown Error")
            return False
        return True

    def get_info(self,desired_info):       
        text = ""
        try:
            if desired_info[0] is True:
                elem = self.wait.until(EC.presence_of_element_located((By.XPATH,"/html/body/form[2]/div/table[2]/tbody/tr/td/table/tbody/tr[3]/td[2]/table/tbody/tr[2]/td[2]/span[1]/div[1]/table/tbody/tr[2]/td[3]")))
                text += (elem.text)
                
            if desired_info[1] is True: #phone number
                elem = self.wait.until(EC.presence_of_element_located((By.XPATH,"/html/body/form[2]/div/table[2]/tbody/tr/td/table/tbody/tr[3]/td[2]/table/tbody/tr[2]/td[2]/span[1]/div[1]/table/tbody/tr[3]/td[3]/span")))
                text += (',' + elem.text)
                '''
                #if phone number is (000)000-0000 then memo the account
                if elem.text.contains("(000)"):
                    self.navigate_to('Memo Screen')
        
                    #write memo
                    try:
                        memoSubject = self.wait.until(EC.presence_of_element_located((By.ID,"memoSubject")))
                        memoBody    = self.wait.until(EC.presence_of_element_located((By.ID,"memoBody")))
                        memoSubject.clear()
                        memoBody.clear()
                        memoSubject.send_keys("")
                        memoBody.send_keys("")
                    except:
                        return "error"
                '''
                
            if desired_info[2] is True:
                elem = self.wait.until(EC.presence_of_element_located((By.XPATH,"/html/body/form[2]/div/table[2]/tbody/tr/td/table/tbody/tr[3]/td[2]/table/tbody/tr[2]/td[2]/span[1]/div[3]/table/tbody/tr[1]/td[3]")))
                text += (',' + elem.text)
                
            if desired_info[3] is True:
                elem = self.wait.until(EC.presence_of_element_located((By.XPATH,"/html/body/form[2]/div/table[2]/tbody/tr/td/table/tbody/tr[3]/td[2]/table/tbody/tr[2]/td[2]/span[1]/div[3]/table/tbody/tr[3]/td[3]")))
                text += (',' + elem.text)
                
            if desired_info[4] is True:
                elem = self.wait.until(EC.presence_of_element_located((By.XPATH,"/html/body/form[2]/div/table[2]/tbody/tr/td/table/tbody/tr[3]/td[2]/table/tbody/tr[2]/td[2]/span[1]/div[7]/div[2]/table/tbody/tr[2]/td[2]")))
                text += (',' + elem.text)
                
            if desired_info[5] is True:
                elem = self.wait.until(EC.presence_of_element_located((By.XPATH,"/html/body/form[2]/div/table[2]/tbody/tr/td/table/tbody/tr[3]/td[2]/table/tbody/tr[2]/td[2]/span[1]/div[7]/div[2]/table/tbody/tr[3]/td[2]")))
                text += (',' + elem.text)
                
            if desired_info[6] is True:
                elem = self.wait.until(EC.presence_of_element_located((By.XPATH,"/html/body/form[2]/div/table[2]/tbody/tr/td/table/tbody/tr[3]/td[2]/table/tbody/tr[2]/td[2]/span[1]/div[7]/div[2]/table/tbody/tr[4]/td[2]")))
                text += (',' + elem.text)
                
            if desired_info[7] is True:
                elem = self.wait.until(EC.presence_of_element_located((By.XPATH,"/html/body/form[2]/div/table[2]/tbody/tr/td/table/tbody/tr[3]/td[2]/table/tbody/tr[2]/td[2]/span[1]/div[7]/div[2]/table/tbody/tr[6]/td[2]/b/span[1]")))
                text += (',' + elem.text)
                
            if desired_info[8] is True:
                elem = self.wait.until(EC.presence_of_element_located((By.XPATH,"/html/body/form[2]/div/table[2]/tbody/tr/td/table/tbody/tr[3]/td[2]/table/tbody/tr[2]/td[2]/span[1]/div[7]/div[2]/table/tbody/tr[7]/td[2]")))
                text += (',' + elem.text)
                
            if desired_info[9] is True:
                elem = self.wait.until(EC.presence_of_element_located((By.XPATH,"/html/body/form[2]/div/table[2]/tbody/tr/td/table/tbody/tr[3]/td[2]/table/tbody/tr[2]/td[2]/span[1]/div[7]/div[2]/table/tbody/tr[9]/td[2]")))
                text += (',' + elem.text)
                
            if desired_info[10] is True:
                elem = self.wait.until(EC.presence_of_element_located((By.XPATH,"/html/body/form[2]/div/table[2]/tbody/tr/td/table/tbody/tr[3]/td[2]/table/tbody/tr[2]/td[2]/span[1]/div[7]/div[2]/table/tbody/tr[10]/td[2]")))
                text += (',' + elem.text)
            
            if desired_info[11] is True:
                elem = self.wait.until(EC.presence_of_element_located((By.XPATH,"/html/body/form[2]/div/table[2]/tbody/tr/td/table/tbody/tr[3]/td[2]/table/tbody/tr[2]/td[2]/span[1]/div[3]/table/tbody/tr[2]/td[3]")))
                text += (',' + elem.text)

            if desired_info[12] is True:
                self.wait.until(EC.presence_of_element_located((By.ID,"top1"))).click()
                elem = self.wait.until(EC.presence_of_element_located((By.XPATH,"/html/body/form[2]/div/table[2]/tbody/tr/td/table/tbody/tr[3]/td[2]/table/tbody/tr[2]/td[2]/span[2]/table[1]/tbody/tr[3]/td[2]")))
                text += (',' + "\"" + elem.text + "\"")

        except:
            return "error"


        #remove first comma if there is one
        if len(text) > 0:
            if text[0] == ',':
                text = text[1:]

        #check to see if the pull was successful
        wasInfo = False
        for i in desired_info:
            if i:
                wasInfo = True
                break
        if wasInfo is True and text == "":
            print("Error pulling data")

        return text

    '''
    Description: Searches memos to see if anything has been mailed to a cient
                 Expects to be on an account screen.
    '''
    def search_for_mail(self):
        
        try:
            #go to notices tab
            self.wait.until(EC.presence_of_element_located((By.ID,"top6"))).click() 
            notices_table = self.wait.until(EC.presence_of_element_located((By.XPATH,"/html/body/form[2]/div/table[2]/tbody/tr/td/table/tbody/tr[3]/td[2]/table/tbody/tr[2]/td[2]/span[7]/table[1]")))           
        except TimeoutException:
            print("Could not find search bar")
            return False
        except:
            print("Unknown Error")
            return False
        
        lines = notices_table.text.split('\n')
        last_sent = lines[-1]
        index_of_date = last_sent.rfind(" ")
        return (last_sent[:index_of_date] + ',' + last_sent[index_of_date+1:])



'''
Description: Determines the appropriate memo based on the description
'''
def memo_Message(description,memo):
    if(description.upper() == "Answering Machine".upper()):
        return memo[0]
    elif(description.upper() == "Connected".upper()):
        return memo[1]
    elif(description.upper() == "No Answer".upper()):
        return memo[2]
    elif(description.upper() == "Invalid Phone Number".upper()):
        return memo[3]
    else:
        print("The call description <",description,"> does not match. Should be\n1)Answering Machine\n2)Connected\n3)No Answer\n4)Invalid Phone Number")
        return "Invalid Decsription"

'''
Description: Concatenates the subject into a single string
'''
#format_Subject(row[1],row[2],row[11],row[8],row[9],row[13],otherContracts)):
def format_Subject(contact_name,dial_number,call_start_time,call_end_time,message_id,job_id,other_contract_number):
    subject = ("DIAL NUMBER: [" + dial_number + '] ' +
              "CALL START TIME: [" + call_start_time + '] ' +
              "CALL END TIME: [" + call_end_time + '] ' +
              "MESSAGE ID: [" + message_id + '] ' +
              "JOB ID: [" + job_id + '] ')
    if other_contract_number:
        subject += ("Other Contracts: [" + other_contract_number + '] ')
        
    return subject

# Description: Takes a string as input. Determines if the string is JSON data 
#              or a file path. Returns the data contained within as a list
# Input:
#   data [String] - Expected to be a file path to DetailedReport.csv or list
#                   of JSON data
def load_report(data):
    rows = []
    # data is a csv filePath
    if(os.path.isfile(data) and data.endswith('.csv')):
        inputFile = data
        with open(inputFile, mode = 'r',encoding = 'utf-8') as csv_file:
            counter = 0
            csv_reader = csv.reader(csv_file,delimiter=',')
            for row in csv_reader:
                if counter != 0:
                    rows.append(row)
                counter = counter + 1
        return rows

    # data is a .json file
    if(os.path.isfile(data) and data.endswith('.json')):
        inputFile = data
        with open(inputFile, mode = 'r',encoding = 'utf-8') as file:
            contents = file.read()
            contentsJson = json.loads(contents)
            data = contentsJson['calldata']
      
    # data is a json list
    json_list = json.loads(data)
    for item in json_list:
        row = [item['ContactName'], item['DialNumber'],      item['Description'],
            item['CallAttempts'],item['CallerNumber'],    item['ScheduledTime'],
            item['CallDuration'],item['EndTime'],         item['MessageId'],
            item['KeyHitByUser'],item['AllKeysHitByUser'],item['StartTime'],
            item['CallRingTime'],item['JobId'],           item['var1'],
            item['var2'],        item['var3'],            item['var4']
            ]
        rows.append(row)
    return rows

''' 
Memo Accounts Main Driver
'''        
'''
argv[1] -> inputFile or JSON [string]
argv[2] -> headless [bool]
argv[3] -> login [string]
argv[4] -> password [string]
argv[5] -> memoBody [string] ex. "Answering Machine,Connected,No Answer,Invalid Phone Number" 
argv[6] -> chromedriver path
argv[7]
'''

rows = []
success = []
failed = []


#set and check arguments
if len(sys.argv) < 5:
    exit("Did not enter all arguments")
inputData = sys.argv[1]

#memo'ing info
memos = sys.argv[5].split(',')
if len(memos) != 4:
    exit("Expected 4 subject memos but " + str(len(memos)) + " were given\n" + "".join(memos))
    
# get contact data
rows = load_report(sys.argv[1])
num_contracts = len(rows)

te = ThirdEye("head",sys.argv[6])
te.login(sys.argv[3],sys.argv[4])
te.navigate_to('Search Page')

#Memo Accounts
#row is a row from the input csv file. Represented as an array of strings
count = 0
estimated_time = 0
start_time = time.time()

for row in rows:   
    
    #add notice type and date if applicable
    #only applies in regards to Return Mail Project
    
    # ===
    #if len(row) > 15:
    #    notice_type_and_date = ". MESSAGE REGARDING " + row[15] + " NOTICE MAILED ON " + row[14]
    #else:
    #    notice_type_and_date = ""
    # ===
    notice_type_and_date = ""
    contract_nums = row[17].split('and') 
    
    #n is a single contract number
    for n in contract_nums:
        tmp = contract_nums.copy()
        tmp.remove(n)
        otherContracts =  ''
    
        for x in tmp:
            x.replace(" ","")
            if x != tmp[-1]:
                otherContracts += (x + ', ')
            else:
                otherContracts += x
        
        count += 1
        percent = count / len(rows)
        
        if te.memo_account(n.replace(" ",""),
                           memo_Message(row[2],memos) + notice_type_and_date, 
                           format_Subject(row[0],row[1],row[11],row[7],row[8],row[13],otherContracts)):
            success.append([n.replace(" ",""),row[1:]])
            print(percent, "~", estimated_time, "~success~", row, flush=True) #sent to Qt process
        else:
            failed.append([n.replace(" ",""),row[1:]])
            print(percent, "~", estimated_time, "~failed~", row, flush=True) #sent to Qt process
        te.navigate_to('Search Page')

        avg_time = (time.time() - start_time) / count
        estimated_time = (avg_time * (num_contracts - count)) /  60
        #print(avg_time/60,estimated_time,flush=True)
    
#print('success:',success)
print('failed:',failed)