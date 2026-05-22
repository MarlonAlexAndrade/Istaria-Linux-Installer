# Istaria: Chronicles of the Gifted — Performance Optimizer
**Author / Autor:** Marlon Alex Andrade

---

## 🇧🇷 Português

### O que é isso?
Um otimizador de performance para o **Istaria: Chronicles of the Gifted**.
Instala o DXVK para traduzir DirectX 9 para Vulkan, resultando em grande ganho de FPS.

### Melhorias aplicadas
- DXVK — traduz DirectX 9 para Vulkan (ganho de 3x ou mais de FPS)
- Configuração automática de threads do DXVK baseada nos núcleos da CPU

### Estrutura de arquivos necessária
```
📁 istaria-optimizer/
  Istaria-Optimizer.desktop     ← clique para instalar (Linux)
  instalar-otimizacoes.sh       ← script Linux
  instalar-otimizacoes.bat      ← script Windows
  📁 dxvk/
    📁 x32/
      d3d9.dll                  ← DXVK 32-bit
    📁 x64/
      d3d9.dll                  ← DXVK 64-bit
```

### Onde baixar o DXVK
Baixe a versão mais recente em: **https://github.com/doitsujin/dxvk/releases**
- Extraia o arquivo `.tar.gz`
- Copie `x32/d3d9.dll` para `dxvk/x32/`
- Copie `x64/d3d9.dll` para `dxvk/x64/`

### Linux — Passo a passo
1. Baixe todos os arquivos mantendo a estrutura de pastas
2. Clique duas vezes no **`Istaria-Optimizer.desktop`**
3. Clique em **"Run"** ou **"Executar"**
4. Pressione **ENTER** para começar
5. Se tiver mais de uma instalação (Wine/Lutris), escolha o número desejado
6. Aguarde — o script instala o DXVK e configura as threads automaticamente
7. Reinicie o Istaria

### Windows — Passo a passo
1. Baixe todos os arquivos mantendo a estrutura de pastas
2. Clique duas vezes no **`instalar-otimizacoes.bat`**
3. Clique com botão direito → **"Executar como administrador"** se necessário
4. Pressione qualquer tecla para começar
5. Aguarde — o script instala o DXVK e configura as threads automaticamente
6. Reinicie o Istaria

### Resultados observados
- **Antes:** ~18 FPS na cidade com NPCs
- **Depois:** ~64 FPS na cidade com NPCs

---

## 🇺🇸 English

### What is this?
A performance optimizer for **Istaria: Chronicles of the Gifted**.
Installs DXVK to translate DirectX 9 to Vulkan, resulting in a major FPS boost.

### Improvements applied
- DXVK — translates DirectX 9 to Vulkan (3x or more FPS gain)
- Automatic DXVK thread configuration based on CPU core count

### Required file structure
```
📁 istaria-optimizer/
  Istaria-Optimizer.desktop     ← click to install (Linux)
  instalar-otimizacoes.sh       ← Linux script
  instalar-otimizacoes.bat      ← Windows script
  📁 dxvk/
    📁 x32/
      d3d9.dll                  ← DXVK 32-bit
    📁 x64/
      d3d9.dll                  ← DXVK 64-bit
```

### Where to download DXVK
Download the latest release at: **https://github.com/doitsujin/dxvk/releases**
- Extract the `.tar.gz` file
- Copy `x32/d3d9.dll` to `dxvk/x32/`
- Copy `x64/d3d9.dll` to `dxvk/x64/`

### Linux — Step by step
1. Download all files keeping the folder structure
2. Double-click **`Istaria-Optimizer.desktop`**
3. Click **"Run"**
4. Press **ENTER** to start
5. If multiple installations are found (Wine/Lutris), choose the desired number
6. Wait — the script installs DXVK and configures threads automatically
7. Restart Istaria

### Windows — Step by step
1. Download all files keeping the folder structure
2. Double-click **`instalar-otimizacoes.bat`**
3. Right-click → **"Run as administrator"** if needed
4. Press any key to start
5. Wait — the script installs DXVK and configures threads automatically
6. Restart Istaria

### Results observed
- **Before:** ~18 FPS in city with NPCs
- **After:** ~64 FPS in city with NPCs
