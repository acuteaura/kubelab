package main

import (
	"html/template"
	"log"
	"net/http"
	"strconv"
)

type StatusCodeDescription struct {
	Name    string
	Explain string
}

var defaultScd = StatusCodeDescription{
	Name:    "Unknown Error",
	Explain: "An unknown error occurred.",
}

var scdTable = map[int]StatusCodeDescription{
	500: {
		Name:    "Internal Server Error",
		Explain: "The server has encountered a situation it doesn't know how to handle.",
	},
	404: {
		Name:    "Not Found",
		Explain: "The requested resource could not be found.",
	},
	401: {
		Name:    "Unauthorized",
		Explain: "You must supply authentication information to access this resource.",
	},
	403: {
		Name:    "Forbidden",
		Explain: "You are not allowed to access this resource.",
	},
}

const sipsErrorTmpl = `
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta http-equiv="x-ua-compatible" content="ie=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <title>Error {{.status}} - {{.scd.Name}}</title>
    <style>
      body { max-width: 960px; margin: 0 auto; padding: 10vh 10vw; font-family: sans-serif; }
      h1, h2 { margin: 0; }
      h1 { font-size: 1.4rem; }
      h2 { font-size: 0.8rem; margin-top: 2rem; }
      .extra { font-family: monospace; font-size: 0.6rem; margin-top: 1em; }
      .detail { color: #666; margin-top: 0.2em; }
    </style>
  </head>

  <body>
    <h1>{{ .scd.Name }}</h1>
    <p>{{ .scd.Explain }}</p>
    <h2>Technical Information</h2>
	<div class="extra">HTTP {{ .status }}: {{ .scd.Name }}<br>
	{{ with .rei.OriginalURI }}<p class="detail">Original URI: {{ . }}</p>{{ end }}
	{{ with .rei.IngressName }}<p class="detail">Ingress: {{ . }}</p>{{ end }}
	</div>
  </body>
</html>
`

type requestErrorInfo struct {
	Code        int
	Format      string
	OriginalURI string
	Namespace   string
	IngressName string
	Servicename string
	ServicePort string
	RequestID   string
}

func parseRequest(r *http.Request) *requestErrorInfo {
	rei := &requestErrorInfo{}
	if code, err := strconv.ParseInt(r.Header.Get("X-Code"), 10, 32); err == nil {
		rei.Code = int(code)
	} else {
		rei.Code = 404
	}

	rei.Format = r.Header.Get("X-Format")
	rei.OriginalURI = r.Header.Get("X-Original-URI")
	rei.IngressName = r.Header.Get("X-Ingress-Name")
	rei.Namespace = r.Header.Get("X-Namespace")
	rei.Servicename = r.Header.Get("X-Service-Name")
	rei.ServicePort = r.Header.Get("X-Service-Port")

	return rei
}

func main() {
	var errorTemplate *template.Template
	errorTemplate = template.New("error")
	_, err := errorTemplate.Parse(sipsErrorTmpl)
	if err != nil {
		log.Fatalf("%v", err)
	}

	http.ListenAndServe(":8080", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		rei := parseRequest(r)

		w.WriteHeader(rei.Code)

		scd := defaultScd
		if _, ok := scdTable[rei.Code]; ok {
			scd = scdTable[rei.Code]
		}

		_ = errorTemplate.ExecuteTemplate(w, "error", map[string]interface{}{
			"status": rei.Code,
			"scd":    scd,
			"rei":    rei,
		})
	}))
}
