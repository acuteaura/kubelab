package main

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog/log"
)

type authorizationHeaderBinding struct {
	Authorization *string `header:"Authorization" binding:"required"`
}

func main() {
	gin.SetMode(gin.ReleaseMode)
	r := gin.Default()

	r.GET("/barekey/:key", func(c *gin.Context) {
		// read key and check if it's set as bearer token
		key := c.Param("key")
		ahb := &authorizationHeaderBinding{}
		err := c.ShouldBindHeader(ahb)
		if err != nil {
			RespondWithError(c, http.StatusForbidden, errors.New("need authorization header"))
			return
		}
		log.Info().Str("key", key).Str("auth", *ahb.Authorization).Msg("checking bearer token")
		token, err := parseBearerToken(*ahb.Authorization)
		if err != nil {
			RespondWithError(c, http.StatusBadRequest, errors.New("invalid format for bearer token"))
			log.Error().Err(err).Msg("invalid bearer token")
			return
		}
		if token != key {
			log.Error().Msg("token doesn't match key")
			RespondWithError(c, http.StatusForbidden, errors.New("invalid bearer token"))
			return

		}
		log.Info().Msg("request ok")
		c.JSON(http.StatusOK, &ResponseEnvelope{Data: "ok"})
	})
	r.Run()
}
