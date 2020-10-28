CRYSTAL_DOCKER := docker run -v $(shell pwd):/src crystallang/crystal
NIM_DOCKER := docker run -v $(shell pwd):/src nimlang/nim

wrk_all: wrk_crystal wrk_nim

crystal_http: crystal_http.cr
	$(CRYSTAL_DOCKER) bash -c "crystal build /src/crystal_http.cr --release --no-debug --static -o /src/crystal_http && chown '1000:1000' /src/crystal_http"

debug:
	$(CRYSTAL_DOCKER) ls -lah /src

wrk_crystal: crystal_http
	test -f .crystal.pid && pkill -F .crystal.pid; true
	test -f .crystal.pid && rm .crystal.pid; true

	bash -c './crystal_http & echo $$! | tee .crystal.pid'
	wrk -t8 -c400 -d15s http://localhost:8080/hello
	@echo 'CRYSTAL RESULT ^^'
	test -f .crystal.pid && pkill -F .crystal.pid; rm .crystal.pid; true


nim_http: nim_http.nim
	$(NIM_DOCKER) bash -c " nim cpp --passL:'-static -no-pie -o /src/nim_http' -d:release --opt:speed --checks:off /src/nim_http.nim && chown '1000:1000' /src/nim_http"

wrk_nim: nim_http
	test -f .nim.pid && pkill -F .nim.pid; true
	test -f .nim.pid && rm .nim.pid; true

	bash -c './nim_http & echo $$! | tee .nim.pid'
	wrk -t8 -c400 -d15s http://localhost:8080/hello
	@echo 'NIM RESULT ^^'
	test -f .nim.pid && pkill -F .nim.pid; rm .nim.pid; true

clean:
	test -f nim_http && rm nim_http || true
	test -f crystal_http && rm crystal_http || true
