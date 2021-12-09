package main

import (
	"fmt"
	"time"
)

const (
	BASE_URL             = "https://metamon-api.radiocaca.com/usm-api"
	TOKEN_URL            = BASE_URL + "/login"
	LIST_MONSTER_URL     = BASE_URL + "/getWalletPropertyBySymbol"
	CHANGE_FIGHTER_URL   = BASE_URL + "/isFightMonster"
	START_FIGHT_URL      = BASE_URL + "/startBattle"
	LIST_BATTLER_URL     = BASE_URL + "/getBattelObjects"
	WALLET_PROPERTY_LIST = BASE_URL + "/getWalletPropertyList"
	LVL_UP_URL           = BASE_URL + "/updateMonster"
	MINT_EGG_URL         = BASE_URL + "/composeMonsterEgg"
)

func main() {
	now := getDateTimeNow()
	fmt.Println(now)
}

func getDateTimeNow() string {
	currentTime := time.Now()

	return currentTime.Format("01/02/2006 15:04:05")
}
