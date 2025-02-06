package main

import (
	"errors"
	"log"
	"net/http"
	"regexp"

	"github.com/gin-gonic/gin"
)

var bearerTokenRegex = regexp.MustCompile("^Bearer ([0-9a-zA-Z-_]*)$")

type authorizationHeaderBinding struct {
	Authorization *string `header:"Authorization" binding:"required"`
}

type ResponseEnvelope struct {
	Data  any    `json:"data,omitempty"`
	Page  *int   `json:"page,omitempty"`
	Pages *int   `json:"pages,omitempty"`
	Error string `json:"error,omitempty"`
}

func main() {
	//gin.SetMode(gin.ReleaseMode)
	r := gin.Default()
	r.GET("/barekey/:key", func(c *gin.Context) {
		// read key and check if it's set as bearer token
		key := c.Param("key")
		ahb := &authorizationHeaderBinding{}
		err := c.ShouldBindHeader(ahb)
		if err != nil {
			log.Println(err)
			RespondWithError(c, http.StatusUnauthorized, errors.New("need authorization header"))
			return
		}
		token, err := parseBearerToken(*ahb.Authorization)
		if err != nil {
			log.Println(err)
			RespondWithError(c, http.StatusBadRequest, errors.New("invalid format for bearer token"))
			return
		}
		if token == key {
			log.Println("sent ok")
			c.JSON(http.StatusOK, &ResponseEnvelope{Data: "ok"})
		} else {
			log.Println("invalid bearer token")
			RespondWithError(c, http.StatusForbidden, errors.New("invalid bearer token"))
		}
	})
	r.Run()
}

func RespondWithError(c *gin.Context, statusCode int, err error) {
	c.Error(err)
	c.Abort()
	c.JSON(statusCode, &ResponseEnvelope{Error: err.Error()})
}

func parseBearerToken(header string) (string, error) {
	matches := bearerTokenRegex.FindStringSubmatch(header)
	if len(matches) != 2 {
		return "", errors.New("invalid bearer token string")
	}
	return matches[1], nil
}
