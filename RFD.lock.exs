# Written by `mix rfd.refs.update`; RFD prose resolves &{...} against it.
%{
  manifest: %{
    repo: "chibifire-smoke-water/contract-manifest-smoke-water",
    commit: "88e0828a44f404f166ee83d8c4e87b1293536398"
  },
  files: %{
    {"MoGe", "moge/model/v3.py"} => %{contains: []},
    {"anny-render-corpus", "anny_rig.py"} => %{contains: []},
    {"datasource-store", "fly/backup-fresh.sh"} => %{contains: []},
    {"egit", "c_src/git_branch.hpp"} => %{contains: []},
    {"egit", "c_src/git_checkout.hpp"} => %{contains: []},
    {"egit", "c_src/git_merge.hpp"} => %{contains: []},
    {"egit", "c_src/git_status.hpp"} => %{contains: []},
    {"interactor-anny", "src/anny/models/soma.py"} => %{contains: []},
    {"interactor-anny", "test/test_soma.py"} => %{contains: []},
    {"interactor-editscore-lora-qwen3vl-4b", "scripts/gate_vision_encoder.py"} => %{
      contains: []
    },
    {"interactor-editscore-lora-qwen3vl-4b", "scripts/smoke.py"} => %{
      contains: []
    },
    {"interactor-editscore-lora-qwen3vl-4b", "scripts/smoke_editscore_mlx.py"} => %{
      contains: []
    },
    {"interactor-kimodo-text-to-motion", "scripts/verify_projection.py"} => %{
      contains: []
    },
    {"interactor-kimodo-text-to-motion", "scripts/verify_projection_vertex.py"} => %{
      contains: []
    },
    {"interactor-soma-x", "soma/identity_model.py"} => %{contains: []},
    {"interactor-taskweft-nmm-personas", "c_src/weft_bus_nif.cpp"} => %{
      contains: []
    }
  },
  repos: %{
    "entities-godot-sandbox" => %{state: :planned, side: "4-entities"},
    "interactor-av1mkv" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/av1mkv",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-av1mkv",
      tip: "da96755140694b06953e865013176161f78bff80"
    },
    "entities-godot-sandbox-gdscript-compiler" => %{
      default: "main",
      state: :placed,
      path: "4-entities/godot-sandbox-gdscript-compiler",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/entities-godot-sandbox-gdscript-compiler",
      tip: "fdbef5d010acccfaa4e9b88cab531105edaf5b7d"
    },
    "interactor-voice" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/voice",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-voice",
      tip: "9d331d4dcc2a52f7eb55c7c6304817af09421eec"
    },
    "chibifire/starforged-std-3001-appendix-e" => %{
      default: "main",
      state: :placed,
      path: "6-datasource/starforged-std-3001-appendix-e",
      revision: "main",
      url: "https://huggingface.co/datasets/chibifire/starforged-std-3001-appendix-e",
      tip: "6b65d8c6368e0f146fc22bf0796751737c94054f"
    },
    "nif" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/taskweft-nif",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/nif",
      tip: "75978b8423b3323f8f63df70781667a954f357ab"
    },
    "ggml" => %{
      default: "main",
      state: :placed,
      path: "2-contract/ggml",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/ggml",
      tip: "29cae86726d8ae2b4d699d8e432fd1bb1801e959"
    },
    "anny-render-corpus" => %{
      default: "main",
      state: :placed,
      path: "6-datasource/anny-render-corpus",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/anny-render-corpus",
      tip: "9ba2f7f3e06bb7283b987cf6259316618417a9ff"
    },
    "contract-cineform-movie-writer" => %{
      default: "main",
      state: :placed,
      path: "2-contract/cineform-movie-writer",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-cineform-movie-writer",
      tip: "34eb224e343ffdc4b64bd881e17e2a0cec1e5609"
    },
    "contract-bootstrap" => %{
      default: "main",
      state: :placed,
      path: "2-contract/bootstrap",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-bootstrap",
      tip: "996822977e15d1c59c1b7faac76f2cd738a98a7d"
    },
    "contract-anny-kernels" => %{
      default: "main",
      state: :placed,
      path: "2-contract/anny-kernels",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-anny-kernels",
      tip: "6727055d6a5a9c7b102f5c40573cb3e27fdb7e4e"
    },
    "service-godot-build" => %{
      default: "main",
      state: :placed,
      path: "7-service/godot-build",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/service-godot-build",
      tip: "cd01a53443763b981a58a847ee779d2f532dcd15"
    },
    "interactor-usd-guest" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/usd-guest",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-usd-guest",
      tip: "c4e4743f3cc9b8171c4a59aa545bfd83e51528b6"
    },
    "entities-anny-creator" => %{
      default: "main",
      state: :placed,
      path: "4-entities/anny-creator",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/entities-anny-creator",
      tip: "0aea2924f287b34d7816f6b20c644823d22d4e2a"
    },
    "datasource-foundationdb" => %{
      default: "main",
      state: :placed,
      path: "6-datasource/foundationdb",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/datasource-foundationdb",
      tip: "511db35cb0837e7d524e97b53674115be3bfc127"
    },
    "character-marocchino" => %{
      default: "main",
      state: :placed,
      path: "4-entities/character-marocchino",
      revision: "main",
      url: "https://github.com/chibifire-stages/character-marocchino",
      tip: "dcd38ff7f6f2ea10a584dca383a6b7c3fab27d36"
    },
    "transport-elixir-libgodot-connector" => %{
      default: "main",
      state: :placed,
      path: "1-transport/elixir-libgodot-connector",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/transport-elixir-libgodot-connector",
      tip: "2747e6fe378fe1abc1d002912a9b19c21c1b23b9"
    },
    "interactor-anny" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/anny",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-anny",
      tip: "fed2f9a23f065dead04fdb180f0b9ebee2ca0b0f"
    },
    "interactor-nx-ggml" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/nx-ggml",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-nx-ggml",
      tip: "c6f7b34bc06f2c5682a5e059665c636429a7d55d"
    },
    "character-mille-mire-feuille" => %{
      default: "main",
      state: :placed,
      path: "4-entities/character-mille-mire-feuille",
      revision: "main",
      url: "https://github.com/chibifire-stages/character-mille-mire-feuille",
      tip: "ee77c5b1198b441bf261fe27e85dd2f86e1781ff"
    },
    "egit" => %{
      default: "main",
      state: :placed,
      path: "4-entities/egit",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/egit",
      tip: "66066a43747d4d057a22b540d74fb643ecc764fe"
    },
    "frame-controller-sim" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/frame-controller-sim",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/frame-controller-sim",
      tip: "bf4a1beedd993afb3400ce07104b731e879a8ab4"
    },
    "manuals-weftspun" => %{
      default: "main",
      state: :placed,
      path: "2-contract/manuals-weftspun",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/manuals-weftspun",
      tip: "86b4ae2ed6d8b499e6cfdc533afac4884734b896"
    },
    "contract-anny-keypoint-anchors" => %{
      default: "main",
      state: :placed,
      path: "2-contract/anny-keypoint-anchors",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-anny-keypoint-anchors",
      tip: "7139b12b19df6b9026e4188292e9231e6b3fc887"
    },
    "contract-ggml-rd" => %{
      default: "main",
      state: :placed,
      path: "2-contract/ggml-rd",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-ggml-rd",
      tip: "6a5654b0c61148df4a2f523ebc2d2d258a12ecb6"
    },
    "interactor-kimodo-text-to-motion" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/kimodo-text-to-motion",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-kimodo-text-to-motion",
      tip: "b4290c704e69722b24c176e7c58a61a07f363384"
    },
    "interactor-soma-x" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/soma-x",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-soma-x",
      tip: "61c36f401cf0eb369cf0737301f85695fc4d200f"
    },
    "contract-guest-common" => %{
      default: "main",
      state: :placed,
      path: "2-contract/guest-common",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-guest-common",
      tip: "1ea61e04bd8e91dfabbf9f36c58de736e5540077"
    },
    "datasource-cassie" => %{
      default: "master",
      state: :placed,
      path: "6-datasource/cassie",
      revision: "master",
      url: "https://github.com/v-sekai/datasource-cassie",
      tip: "ed6870db441ece00701979db67190972deeff59b"
    },
    "service-cineform" => %{
      default: "main",
      state: :placed,
      path: "7-service/cineform",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/service-cineform",
      tip: "a6b30a2f63f73f8596455578bb67e59ff9590b9f"
    },
    "entities-sakuragaoka-station" => %{
      default: "main",
      state: :placed,
      path: "4-entities/sakuragaoka-station",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/entities-sakuragaoka-station",
      tip: "65c169b387a225f28cf2a81ac64f84426be50975"
    },
    "transport-meshing-pen" => %{
      default: "main",
      state: :placed,
      path: "1-transport/meshing-pen",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/transport-meshing-pen",
      tip: "f75d726e1eee988584c9036e8749b36371c2caad"
    },
    "transport-central-launcher" => %{
      default: "main",
      state: :placed,
      path: "1-transport/central-launcher",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/transport-central-launcher",
      tip: "fb961f3d0b9766cba66c2b9700874b1042b8b9e2"
    },
    "repository-riscv64-sysroot" => %{
      default: "main",
      state: :placed,
      path: "5-repository/riscv64-sysroot",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/repository-riscv64-sysroot",
      tip: "05a47642f334b281f36bfd889e92c8c0bfb5f545"
    },
    "interactor-taskweft-godot-sandbox" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/taskweft-godot-sandbox",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-taskweft-godot-sandbox",
      tip: "b94aee9a0d52dd2ce05cc692a4e8094b55aaf820"
    },
    "entities-godot" => %{
      default: "main",
      state: :placed,
      path: "4-entities/godot-cineform",
      revision: "dev/cineform",
      url: "https://github.com/V-Sekai-fire/entities-godot",
      tip: "1249dfc65fdba17f458da0330ed9accf5421757b"
    },
    "godot_openvr" => %{
      default: "main",
      state: :placed,
      path: "4-entities/godot-openvr",
      revision: "feat/frame-devices",
      url: "https://github.com/V-Sekai-fire/godot_openvr",
      tip: "04c84ba1654ba6f9bb974a065bbb23aabf627a52"
    },
    "pyrowave" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/pyrowave-upstream",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/pyrowave",
      tip: "a2527babe8390d5c59cf9c29fbae8c5f5022b2b3"
    },
    "contract-zone-backend" => %{
      default: "main",
      state: :placed,
      path: "2-contract/zone-backend",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-zone-backend",
      tip: "cda66e317c527239315169c1dd08ca3ecb47991b"
    },
    "interactor-drape" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/drape",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-drape",
      tip: "923c9b0d77e438f556f8865143bd5f9e6a63b8f6"
    },
    "interactor-curvenet" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/curvenet",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-curvenet",
      tip: "c4e73831ab5718f3baf730da2e77d51ff9d02b03"
    },
    "kimodo-ggml" => %{
      default: "main",
      state: :archived,
      url: "https://github.com/V-Sekai-archive/kimodo-ggml",
      tip: "9e62d0ed6bd06fa2890ce92d752a40ae204f1f85"
    },
    "contract-bus" => %{
      default: "main",
      state: :placed,
      path: "2-contract/bus",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-bus",
      tip: "9b76303f51d60b5fdda23582022e0fd9e190430e"
    },
    "service-bao-sqlite-fdb" => %{
      default: "main",
      state: :placed,
      path: "7-service/bao-sqlite-fdb",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/service-bao-sqlite-fdb",
      tip: "870e48cc6a982fcc9bce3013ad2f10860d7b56bd"
    },
    "transport-cineform-tui" => %{
      default: "main",
      state: :placed,
      path: "1-transport/cineform-tui",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/transport-cineform-tui",
      tip: "2d8856d2c9f7863dbee12040b107753a4abb5aaf"
    },
    "MoGe" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/moge-upstream",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/MoGe",
      tip: "1bb5557171d4634d2c792b7af2e8ecca5147e991"
    },
    "contract-lbfgsb" => %{
      default: "main",
      state: :placed,
      path: "2-contract/lbfgsb",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-lbfgsb",
      tip: "449bb7d6a375ee534ffc8cc85dba7aa6076676a6"
    },
    "sakuragaoka-station" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/sakuragaoka-station-upstream",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/sakuragaoka-station",
      tip: "f7cf5ac562149d1454da9b8f0b0d15a847d54226"
    },
    "interactor-editscore-lora-qwen3vl-4b" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/editscore-lora-qwen3vl-4b",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-editscore-lora-qwen3vl-4b",
      tip: "41469ab5ed762722e61107b8bb9834156db98eff"
    },
    "interactor-taskweft" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/taskweft",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-taskweft",
      tip: "e9a0ee8ca35888b47754d30adca08a3bf82d0438"
    },
    "contract-guest-runtime" => %{
      default: "main",
      state: :placed,
      path: "2-contract/guest-runtime",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-guest-runtime",
      tip: "1d8341825ac6fcfa8b8b2a11ae908e5d6aa71b33"
    },
    "interactor-motion-guest" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/motion-guest",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-motion-guest",
      tip: "c8af0b2b872dda729842e0f76f2e13fcdb05f62d"
    },
    "interactor-taskweft-nmm-personas" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/taskweft-nmm-personas",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-taskweft-nmm-personas",
      tip: "476555a8a38eb562687a45effc569dcbebe70c5b"
    },
    "interactor-mujoco-sandbox-demo" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/mujoco-sandbox-demo",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-mujoco-sandbox-demo",
      tip: "f93828bc3a2730ccc34e49c18ae0b73479ae34f0"
    },
    "interactor-rfdetr-seg-guest" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/rfdetr-seg-guest",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-rfdetr-seg-guest",
      tip: "0925d4873e472fcceb29b6cf0047f2d06da6fa98"
    },
    "service-taskweft-bao" => %{state: :planned, side: "7-service"},
    "contract-hm08-partition" => %{
      default: "main",
      state: :placed,
      path: "2-contract/hm08-partition",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-hm08-partition",
      tip: "3dfe1a6c13d6a6d146621e638172c428271ca317"
    },
    "contract-sinew-align" => %{
      default: "main",
      state: :placed,
      path: "2-contract/sinew-align",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/contract-sinew-align",
      tip: "7e00cdb42aeba6dcc8e263898096a6c4c55e2a47"
    },
    "interactor-lasso" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/lasso",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-lasso",
      tip: "2610aac5e0393c88c706ebff43c5f7f158a4ed6a"
    },
    "interactor-cineform" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/cineform",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-cineform",
      tip: "e7e64492be75e884e81644a28be01b2094a46e81"
    },
    "service-sqlar-cas" => %{
      default: "main",
      state: :archived,
      url: "https://github.com/V-Sekai-archive/service-sqlar-cas",
      tip: "bc157f34d78018d0b81980b9d57ab0cfea339e84"
    },
    "transport-usbip-frame" => %{
      default: "main",
      state: :placed,
      path: "1-transport/usbip-frame",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/transport-usbip-frame",
      tip: "c222b2b60a83efb1f09449211521345908a118d6"
    },
    "contract-manifest-skateboard" => %{state: :planned, side: "2-contract"},
    "trust-lean" => %{
      default: "main",
      state: :placed,
      path: "2-contract/trust-lean",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/trust-lean",
      tip: "39a6c2672d2b32ad3acce34b3126ab6593d3cc93"
    },
    "interactor-rf-detr-ggml" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/rf-detr-ggml",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-rf-detr-ggml",
      tip: "a149e6c8418053773c3c53ca8365845325e65d46"
    },
    "interactor-fabric-zone" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/fabric-zone",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-fabric-zone",
      tip: "aa58c1d88f252a32fd916a8137e59d1d4b06fa8d"
    },
    "service-zone" => %{
      default: "main",
      state: :placed,
      path: "7-service/zone",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/service-zone",
      tip: "747c037d659c08a4f09cfbd729dbba2e2a0a8cf1"
    },
    "service-openbao" => %{
      default: "main",
      state: :placed,
      path: "7-service/openbao",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/service-openbao",
      tip: "a80cb3d81cf7352fd42adf74ebd4d99ce8e6ea00"
    },
    "datasource-store" => %{
      default: "main",
      state: :placed,
      path: "6-datasource/store",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/datasource-store",
      tip: "abb688b70be3dc160c2cf5f32ff7d8e05da799ba"
    },
    "interactor-flow" => %{
      default: "main",
      state: :placed,
      path: "3-interactor/datasource-flow",
      revision: "main",
      url: "https://github.com/V-Sekai-fire/interactor-flow",
      tip: "5b4dcda095b7f062bc2e40b8950ce94e55ddcdd1"
    }
  }
}
