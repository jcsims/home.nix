package main

import (
	"bytes"
	"io/ioutil"
	"os"
	"os/exec"
	"path"
	"strings"
)

var superscripts = []string{"⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹"}

func gitDir() (string, bool) {
	cpath, e := os.Getwd()
	if e != nil {
		return "", false
	}

	for {
		stat, err := os.Stat(cpath + "/.git")
		if !os.IsNotExist(err) && stat.IsDir() {
			return cpath + "/.git", true
		}
		if cpath == "/" {
			return "", false
		}
		cpath = path.Dir(cpath)
	}
}

func gitInfo() string {
	gitDir, ok := gitDir()
	if !ok {
		return ""
	}
	cmd := exec.Command("git", "status", "--porcelain")
	o, e := cmd.Output()
	if e != nil {
		return e.Error()
	}

	color := fgGreen
	if len(o) > 0 {
		color = fgMagenta
	}

	o, e = ioutil.ReadFile(gitDir + "/HEAD")
	if e != nil {
		return " error"
	}
	ref := ""
	branch := ""
	if string(o[0:16]) == "ref: refs/heads/" {
		ref = strings.TrimSpace(string(o[16:]))
		branch = ref
	} else {
		ref = string(o[0:8])
	}

	if (ref == "master" || ref == "main") {
		ref = "𝒎"
	}

	syncstat := fgYellow + " ≟"
	if branch != "" {
		remoteSHA := []byte{}
		localSHA, err := ioutil.ReadFile(gitDir + "/refs/heads/" + branch)
		if err != nil {
			goto welp
		}

		if _, err := os.Stat(gitDir + "/refs/remotes/origin/" + branch); err == nil {
			remoteSHA, err = ioutil.ReadFile(gitDir + "/refs/remotes/origin/" + branch)
			if err != nil {
				goto welp
			}
			if bytes.Compare(remoteSHA, localSHA) == 0 {
				syncstat = ""
			} else {
				syncstat = fgRed + " ≠"
			}
		}
	}

welp:

	stashCount := 0

	if o, e = ioutil.ReadFile(gitDir + "/logs/refs/stash"); e == nil {
		stashCount = bytes.Count(o, []byte{'\n'})
	}

	stash := ""
	if stashCount > 0 {
		count := stashCount
		if count > 9 {
			count = 9
		}
		stash = fgWhite + superscripts[count]
	}

	pending := fgRed
	if _, err := os.Stat(gitDir + "/rebase-merge"); err == nil {
		pending += "ᴿ"
	}
	if _, err := os.Stat(gitDir + "/CHERRY_PICK_HEAD"); err == nil {
		pending += "ᴾ"
	}
	if _, err := os.Stat(gitDir + "/MERGE_HEAD"); err == nil {
		pending += "ᴹ"
	}

	return " " + stash + color + ref + pending + syncstat
}
