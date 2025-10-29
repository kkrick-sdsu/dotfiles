# Dotfiles

Useful configs for use across servers/shells

## Download

```bash
git clone https://github.com/kkrick-sdsu/dotfiles.git ~/.dotfiles
```

## Link

```bash
ln -s ~/.dotfiles/vim/.vimrc ~/.vimrc
ln -s ~/.dotfiles/vim/.vim ~/.vim
```

## Install

### ViM

Install vim-plug
```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Install plugins
```bash
:PlugInstall
```
