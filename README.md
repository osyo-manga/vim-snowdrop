#snowdrop.vim

##Requirement

* __Vim supported__
 * `+python`
* __[Clang 3.3](http://llvm.org/releases/download.html#3.3) or [3.4](http://llvm.org/releases/download.html#3.4)__
 * libclang dynamic link binary.
 * Windows : libclang.dll
 * Mac     : libclang.dylib
 * Other   : libclang.so


##Supported

* Goto definition/declaration.
 * `:SnowdropGotoDefinition`
* Type of.
 * `:SnowdropEchoTypeof`
* Typeof on balloon.
* Function result type of.
 * `:SnowdropEchoResultTypeof`
* Includes
 * `:SnowdropEchoIncludes`
 * `:Unite snowdrop/includes`
* Outline
 * `:Unite snowdrop/outline`


##Install

####neobundle.vim
```vim
NeoBundle "osyo-manga/vim-snowdrop"
```


##Setting

```vim
" set libclang directory path
let g:snowdrop#libclang_directory = "C:/llvm/bin"

" set include directory path.
let g:snowdrop#include_paths = {
\	"cpp" : {
\		"C:/cpp/boost",
\		"C:/cpp/sprout",
\	}
\}

" set clang command options.
let g:snowdrop#command_options = {
\	"cpp" : "-std=c++1y",
\}
```


##Example

####Typeof.

```vim
" Type of cursor
:SnowdropEchoTypeof
```
![typeof](http://gyazo.com/490e613d0658f0790d9e063f346c90ff.png)


###Typeof on balloon.

```vim
function! s:cpp()
    setlocal balloonexpr=snowdrop#ballonexpr_typeof()
    setlocal ballooneval
endfunction

augroup my-cpp
    autocmd!
    autocmd FileType cpp call s:cpp()
augroup END
```
![balloon](https://f.cloud.github.com/assets/214488/1932966/22262f2e-7ed3-11e3-8ea3-e2ec1858bea4.PNG)

####Result typeof.

```vim
:SnowdropEchoResultTypeof
```
![resulttypeof](http://gyazo.com/ca656cf9f6019b1272b6add3b32c5475.png)


###Include files.

```vim
:SnowdropEchoIncludes
```
![include](http://gyazo.com/4a798e1668e204e35c5e5a5d733d6d62.png)


###Include files on unite.vim.

```vim
:Unite snowdrop/includes
```
![unite-snowdrop_include](https://f.cloud.github.com/assets/214488/1932993/85501f74-7ed3-11e3-9143-4844082e4b4c.PNG)


###Outline on unite.vim.

```vim
:Unite snowdrop/outline
```
![unite-snowdrop_outline](https://f.cloud.github.com/assets/214488/1933045/a4a85278-7ed4-11e3-8ae7-c9ef6639ff24.PNG)


###Code completion.

Use neocomplete.vim.

* [Shougo/neocomplete.vim - github](https://github.com/Shougo/neocomplete.vim)

```vim
" Enable code completion in neocomplete.vim.
let g:neocomplete#sources#snowdrop#enable = 1

" Not skip
let g:neocomplete#skip_auto_completion_time = ""
```
![code_complete](http://gyazo.com/415301c1bd2fbba612eacce057efccc3.png)


##Future


