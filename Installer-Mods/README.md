# Istaria: Chronicles of the Gifted — Mod Manager
**Author / Autor:** Marlon Alex Andrade

---

## 🇧🇷 Português

### O que é isso?
Um gerenciador de mods para o **Istaria: Chronicles of the Gifted** no Linux.
Instala e remove mods com poucos cliques, sem precisar de comandos.

### O que você vai precisar
- Istaria já instalado (via Wine ou Lutris)
- Os dois arquivos na mesma pasta:
  - `Istaria-Mods.desktop`
  - `istaria-mods.sh`

### Mods disponíveis

| Mod | Descrição |
|---|---|
| MapPack 5.0 | Pacote de mapas com texturas e localizações atualizadas |

### Passo a passo

**1.** Coloque os dois arquivos na **mesma pasta**.

**2.** Clique duas vezes no **`Istaria-Mods.desktop`** (ícone de controle de videogame).

**3.** Clique em **"Run"** ou **"Executar"** na janela que aparecer.

**4.** O script vai procurar automaticamente o Istaria instalado no seu sistema.

- Se encontrar em **apenas um lugar** — usa automaticamente.
- Se encontrar no **Wine e no Lutris** — pergunta qual usar:
```
[1] Wine   — /home/usuario/.wine/drive_c/Program Files (x86)/Istaria
[2] Lutris — /home/usuario/Games/istaria
Choose / Escolha: 
```
Digite **1** ou **2** e pressione ENTER.

- Se **não encontrar** — uma mensagem de erro aparece pedindo para instalar o jogo primeiro.

**5.** O menu de mods vai aparecer:
```
[1] Install / Instalar — MapPack 5.0
[2] Remove / Remover  — MapPack 5.0
[3] Exit / Sair
```
Digite o número desejado e pressione ENTER.

**6.** O **MapPackSyncTool** vai abrir via Wine:
- Verifique se o caminho aponta para a pasta do Istaria
- Clique em **"Add / Sync"** para instalar ou atualizar
- Clique em **"Remove"** para desinstalar

**7.** Aguarde terminar. Pronto! 🐉

---

## 🇺🇸 English

### What is this?
A mod manager for **Istaria: Chronicles of the Gifted** on Linux.
Install and remove mods with just a few clicks, no commands needed.

### What you will need
- Istaria already installed (via Wine or Lutris)
- Both files in the same folder:
  - `Istaria-Mods.desktop`
  - `istaria-mods.sh`

### Available mods

| Mod | Description |
|---|---|
| MapPack 5.0 | Map pack with updated textures and locations |

### Step by step

**1.** Place both files in the **same folder**.

**2.** Double-click **`Istaria-Mods.desktop`** (gamepad icon).

**3.** Click **"Run"** on the window that appears.

**4.** The script will automatically search for Istaria on your system.

- If found in **only one place** — uses it automatically.
- If found in **both Wine and Lutris** — asks which to use:
```
[1] Wine   — /home/user/.wine/drive_c/Program Files (x86)/Istaria
[2] Lutris — /home/user/Games/istaria
Choose / Escolha: 
```
Type **1** or **2** and press ENTER.

- If **not found** — an error message appears asking you to install the game first.

**5.** The mod menu will appear:
```
[1] Install / Instalar — MapPack 5.0
[2] Remove / Remover  — MapPack 5.0
[3] Exit / Sair
```
Type the desired number and press ENTER.

**6.** The **MapPackSyncTool** will open via Wine:
- Verify the path points to your Istaria folder
- Click **"Add / Sync"** to install or update
- Click **"Remove"** to uninstall

**7.** Wait for the process to finish. Done! 🐉

---

## Observações / Notes

- 🇧🇷 O script detecta automaticamente Wine e Lutris.
- 🇺🇸 The script automatically detects Wine and Lutris installations.

- 🇧🇷 Novos mods podem ser adicionados no futuro sem reinstalar o jogo.
- 🇺🇸 New mods can be added in the future without reinstalling the game.
