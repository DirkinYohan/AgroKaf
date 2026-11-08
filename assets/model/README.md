# AI model files

Copy here the three files produced by `training/agrokaf_model.ipynb`
(Google Drive `MyDrive/agrokaf/artifacts/` or `agrokaf_flutter_assets.zip`):

| File | Purpose |
|---|---|
| `model_fp16.tflite` | MobileNetV3Large classifier (float16) run offline with LiteRT |
| `labels.txt` | Class names, one per line, in the model's output order (`healthy`, `phoma`) |
| `model_info.json` | Preprocessing contract and test metrics (shown in "Acerca de") |

Final layout:

```
assets/model/
├── labels.txt
├── model_fp16.tflite
├── model_info.json
└── README.md
```

If the files are missing the app does not crash: it shows "Modelo no disponible".
