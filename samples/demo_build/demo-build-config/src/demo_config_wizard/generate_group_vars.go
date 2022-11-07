package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"html/template"
	"io/ioutil"
	"log"
	"os"
)

type GroupVarsVars struct {
	Target_user              string
	Twistlock_registry_token string
	Twistlock_license        string
	New_password             string
	Service_account_email    string
}

func get_svc_account(path string) (string, error) {

	var byteValue []byte

	credJson, err := os.Open(path)
	if err != nil {
		log.Print(err)
		return "", err
	}
	defer credJson.Close()

	byteValue, err = ioutil.ReadAll(credJson)

	var result map[string]string
	json.Unmarshal([]byte(byteValue), &result)

	return result["client_email"], nil

}

func parse_group_vars(group_vars GroupVarsVars) (string, error) {

	var out string

	t, err := template.ParseFiles("assets/all.yml.j2")
	if err != nil {
		log.Print(err)
		return "", err
	}

	buf := new(bytes.Buffer)

	err = t.Execute(buf, group_vars)
	if err != nil {
		log.Print(err)
		return "", err
	}

	out = buf.String()

	return out, nil
}

func main() {

	svc_email, err := get_svc_account("/home/rando/demo_build_config/files/twistlock-cto-lab-486e2047cc78.json")
	if err != nil {
		log.Print(err)
	}
	var group_vars GroupVarsVars
	group_vars.New_password = "p@ssw0rd1"
	group_vars.Target_user = "neil"
	group_vars.Twistlock_license = "blahblahblahblah"
	group_vars.Twistlock_registry_token = "deadbeef"
	group_vars.Service_account_email = svc_email

	out := parse_group_vars(group_vars)
	fmt.Print("%s", out)
}
