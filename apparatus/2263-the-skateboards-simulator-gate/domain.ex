# SPDX-License-Identifier: MIT
# Copyright (c) 2026 K. S. Ernest (iFire) Lee
#
# The Skateboard's pen-meshing pipeline as a RECTGTN goal-regression HTN
# domain (RFD 2263): actions state only what they need and make.
defmodule SkateboardSimulatorGate do
  use Taskweft.DSL

  @name "skateboard_simulator_gate"

  @variables %{
    have: %{
      type: :bool,
      init: %{
        strokes: false,
        curvenet: false,
        mesh: false,
        repaired: false,
        closed_solid: false,
        drape: false,
        garment: false
      }
    },
    # Ship deadline: last day of September 2026, Vancouver time (a value, not a null).
    deadline: %{
      type: :ref,
      init: %{ship: "2026-09-30T23:59:59-07:00"}
    },
    handle: %{
      type: :ref,
      init: %{
        strokes: "",
        curvenet: "",
        mesh: "",
        repaired: "",
        closed_solid: "",
        drape: "",
        garment: ""
      }
    }
  }

  @actions %{
    # Pen strokes to a curve network.
    a_curvenet: %{
      params: [],
      duration: "PT2M",
      body: [
        %{eval: %{type: "math/eq", a: %{pointer_get: "/have/strokes"}, b: true}},
        %{pointer_set: "/have/curvenet", value: true},
        %{pointer_set: "/handle/curvenet", value: "/work/curvenet.usda"}
      ]
    },
    # Curve network to a triangle mesh.
    a_mesh: %{
      params: [],
      duration: "PT5M",
      body: [
        %{eval: %{type: "math/eq", a: %{pointer_get: "/have/curvenet"}, b: true}},
        %{pointer_set: "/have/mesh", value: true},
        %{pointer_set: "/handle/mesh", value: "/work/mesh.usda"}
      ]
    },
    # Voxel remesh to a watertight manifold.
    a_repair: %{
      params: [],
      duration: "PT5M",
      body: [
        %{eval: %{type: "math/eq", a: %{pointer_get: "/have/mesh"}, b: true}},
        %{pointer_set: "/have/repaired", value: true},
        %{pointer_set: "/handle/repaired", value: "/work/repaired.usda"}
      ]
    },
    # Establish the body as a closed solid.
    a_close: %{
      params: [],
      duration: "PT5M",
      body: [
        %{eval: %{type: "math/eq", a: %{pointer_get: "/have/repaired"}, b: true}},
        %{pointer_set: "/have/closed_solid", value: true},
        %{pointer_set: "/handle/closed_solid", value: "/work/closed_solid.usda"}
      ]
    },
    # GPU cloth drape; the rebac/check may-use--gpu guard gates this step.
    a_drape: %{
      params: [],
      duration: "PT20M",
      body: [
        %{eval: %{type: "rebac/check", rel: "may-use--gpu", subject: "hero", object: "gpu-4090"}},
        %{eval: %{type: "math/eq", a: %{pointer_get: "/have/closed_solid"}, b: true}},
        %{pointer_set: "/have/drape", value: true},
        %{pointer_set: "/handle/drape", value: "/work/drape.usda"}
      ]
    },
    # The deliverable garment.
    a_deliver: %{
      params: [],
      duration: "PT5M",
      body: [
        %{eval: %{type: "math/eq", a: %{pointer_get: "/have/drape"}, b: true}},
        %{pointer_set: "/have/garment", value: true},
        %{pointer_set: "/handle/garment", value: "/outputs/garment.usdz"}
      ]
    }
  }

  @methods %{
    have: %{
      params: [:artifact, :desired],
      alternatives: [
        %{
          name: :curvenet,
          check: [%{eval: %{type: "math/eq", a: "{artifact}", b: "curvenet"}}],
          subtasks: [["a_curvenet"]]
        },
        %{
          name: :mesh,
          check: [%{eval: %{type: "math/eq", a: "{artifact}", b: "mesh"}}],
          subtasks: [["have", "curvenet", true], ["a_mesh"]]
        },
        %{
          name: :repaired,
          check: [%{eval: %{type: "math/eq", a: "{artifact}", b: "repaired"}}],
          subtasks: [["have", "mesh", true], ["a_repair"]]
        },
        %{
          name: :closed_solid,
          check: [%{eval: %{type: "math/eq", a: "{artifact}", b: "closed_solid"}}],
          subtasks: [["have", "repaired", true], ["a_close"]]
        },
        %{
          name: :drape,
          check: [%{eval: %{type: "math/eq", a: "{artifact}", b: "drape"}}],
          subtasks: [["have", "closed_solid", true], ["a_drape"]]
        },
        %{
          name: :garment,
          check: [%{eval: %{type: "math/eq", a: "{artifact}", b: "garment"}}],
          subtasks: [["have", "drape", true], ["a_deliver"]]
        }
      ]
    }
  }

  # Relationship-Enabled Capability: hero owns and may use the GPU the drape needs.
  @capabilities %{
    entities: %{"hero" => ["gpu-experimenter"], "frame" => ["headset-runtime"]},
    graph: %{
      edges: [
        %{subject: "hero", rel: "owns", object: "gpu-4090"},
        %{subject: "hero", rel: "may-use--gpu", object: "gpu-4090"},
        %{subject: "frame", rel: "runs-on", object: "headset"}
      ],
      definitions: %{}
    }
  }

  @todo_list [%{goal: [%{pointer: "/have/garment", eq: true}]}]
end
