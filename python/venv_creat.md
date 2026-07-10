1. create virtual environment
```
python3 -m venv ~/Python/HXGPyhton
```
2. activate virtual environment
```
source ~/Python/HXGPyhton/bin/activate
```
3. deactivate virtual environment
```
deactivate
```


导出 pip pkg list -> file

pip freeze > requirements.txt

## Try USE uv

1. install uv

```
curl -LsSf https://astral.sh/uv/install.sh | sh

# update
uv self update

# Shell autocompletion for uv or uvx
# bash
echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc
#zsh
echo 'eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc
# fish
echo 'uv generate-shell-completion fish | source' > ~/.config/fish/completions/uv.fish


# Unistall

uv cache clean
rm -r "$(uv python dir)"
rm -r "$(uv tool dir)"

rm ~/.local/bin/uv ~/.local/bin/uvx

```

2. create v env

uv venv ~/Python/HXPython-uv


active
source ~/Python/HXPython-uv/bin/activate

uv pip install -r requirements.txt

3. use 