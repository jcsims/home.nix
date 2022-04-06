package main

import (
	"fmt"
	"os"
	"path"
	"strconv"
)

var (
	fgReset   = fgColor(0)
	fgBlack   = fgColor(30)
	fgRed     = fgColor(31)
	fgGreen   = fgColor(32)
	fgYellow  = fgColor(33)
	fgBlue    = fgColor(34)
	fgMagenta = fgColor(35)
	fgCyan    = fgColor(36)
	fgWhite   = fgColor(37)
)

func fgColor(color int) string {
	return fmt.Sprintf("%%{\x1b[%dm%%}", color)
}

func pathInfo() string {
	cwd, err := os.Getwd()
	if err != nil {
		cwd = "error"
	}
	color := "%{\x1b[48;5;238m%}"
	reset := "%{\x1b[0m%}"
	return color + path.Base(cwd) + reset
}

func statusAndPrompt() string {
	num, err := strconv.Atoi(os.Args[1])
	if err != nil {
		num = 0
	}
	if num == 0 {
		return ""
	}
	return fgRed + os.Args[1]
}

func pathColor() string {
	if os.Getenv("SSH_CONNECTION") != "" {
		return fgGreen
	} else {
		return fgBlue
	}
}

func main() {
	fmt.Printf("%s%s %s%s%s ", pathColor()+pathInfo(), gitInfo(), statusAndPrompt(), fgReset, "%(1j.%j.)")
}
