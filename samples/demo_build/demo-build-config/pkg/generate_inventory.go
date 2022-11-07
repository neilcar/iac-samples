package demobuildgenerate

import (
	"html/template"
	"log"
	"os"
)

type InventoryVarsVars struct {
	target_user string
	build       string
}

func parse_inventory(inventory_vars InventoryVarsVars) {

	t, err = template.ParseFiles("../assets/inventory.yml.j2")
	if err != nil {
		log.Print(err)
		return
	}

	t.Execute(os.Stdout, inventory_vars)

	return
}
