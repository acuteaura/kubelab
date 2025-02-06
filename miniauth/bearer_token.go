package main

import (
	"errors"
	"regexp"
)

var bearerTokenRegex = regexp.MustCompile("^Bearer ([0-9a-zA-Z-_]*)$")

func parseBearerToken(header string) (string, error) {
	matches := bearerTokenRegex.FindStringSubmatch(header)
	if len(matches) != 2 {
		return "", errors.New("invalid bearer token string")
	}
	return matches[1], nil
}
