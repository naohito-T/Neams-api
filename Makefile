# ログの色
R := \e[31m
G := \e[32m
B := \e[34m
N := \e[0m

# 疑似ターゲット(疑似の依存)
.PHONY: post.commit
post.commit:
	@make _post.root.commit

.PHONY: deploy
deploy:
	@make _deploy.heroku


# git logでコミットIDを出力に入れる(標準出力のみを変数に設定する)
_post.root.commit:
	$(eval VAR := $(shell git log | grep commit | head -n 1))
	@cd ..;\
	git add .;\
	git commit -m "${VAR}";\
	printf '${B}%s\n' "# rootディレクトリもcommitしました. commitID: ${VAR}";\

# mainに変更してgit push
# git ch してmainからpushする
# tagをつける
# heroku ciがあるとのこと
_deploy.heroku:
