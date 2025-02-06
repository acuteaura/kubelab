package main

import "github.com/gin-gonic/gin"

type ResponseEnvelope struct {
	Data  any    `json:"data,omitempty"`
	Page  *int   `json:"page,omitempty"`
	Pages *int   `json:"pages,omitempty"`
	Error string `json:"error,omitempty"`
}

func RespondWithError(c *gin.Context, statusCode int, err error) {
	c.Error(err)
	c.Abort()
	c.JSON(statusCode, &ResponseEnvelope{Error: err.Error()})
}
