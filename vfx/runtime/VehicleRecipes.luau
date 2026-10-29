-- Generated from vfx/vehicle/recipes.py; edit recipe source, then regenerate.
return [==[{
  "AXZFTyreSmoke": [
    {
      "op": "create",
      "className": "Attachment",
      "id": "contact",
      "name": "Contact",
      "parent": "$part"
    },
    {
      "op": "create",
      "className": "ParticleEmitter",
      "name": "SmokeBody",
      "parent": "$contact",
      "properties": {
        "Texture": "rbxassetid://123244819470159",
        "Enabled": false,
        "Rate": 0,
        "Lifetime": [
          0.5,
          0.8
        ],
        "Speed": [
          1.5,
          4
        ],
        "Drag": 5,
        "SpreadAngle": [
          65,
          65
        ],
        "EmissionDirection": "Top",
        "Acceleration": [
          0,
          2,
          0
        ],
        "Rotation": [
          0,
          360
        ],
        "RotSpeed": [
          -40,
          40
        ],
        "Color": [
          0.63,
          0.65,
          0.66
        ],
        "LightEmission": 0,
        "LightInfluence": 1,
        "Size": [
          {
            "time": 0,
            "value": 0.7
          },
          {
            "time": 0.3,
            "value": 2.2
          },
          {
            "time": 1,
            "value": 3.5
          }
        ],
        "Transparency": [
          {
            "time": 0,
            "value": 0.35
          },
          {
            "time": 0.4,
            "value": 0.6
          },
          {
            "time": 1,
            "value": 1
          }
        ]
      },
      "attributes": {
        "EmitCount": 4,
        "EmitDelay": 0
      }
    },
    {
      "op": "create",
      "className": "ParticleEmitter",
      "name": "SecondaryBillow",
      "parent": "$contact",
      "properties": {
        "Texture": "rbxassetid://123244819470159",
        "Enabled": false,
        "Rate": 0,
        "Lifetime": [
          0.7,
          1.05
        ],
        "Speed": [
          1,
          2.5
        ],
        "Drag": 5,
        "SpreadAngle": [
          65,
          65
        ],
        "EmissionDirection": "Top",
        "Acceleration": [
          0,
          1.5,
          0
        ],
        "Rotation": [
          0,
          360
        ],
        "RotSpeed": [
          -40,
          40
        ],
        "Color": [
          0.48,
          0.5,
          0.52
        ],
        "LightEmission": 0,
        "LightInfluence": 1,
        "Size": [
          {
            "time": 0,
            "value": 0.9
          },
          {
            "time": 0.4,
            "value": 2.8
          },
          {
            "time": 1,
            "value": 4
          }
        ],
        "Transparency": [
          {
            "time": 0,
            "value": 0.65
          },
          {
            "time": 0.5,
            "value": 0.8
          },
          {
            "time": 1,
            "value": 1
          }
        ]
      },
      "attributes": {
        "EmitCount": 2,
        "EmitDelay": 0.06
      }
    },
    {
      "op": "create",
      "className": "ParticleEmitter",
      "name": "RoadGrit",
      "parent": "$contact",
      "properties": {
        "Texture": "rbxassetid://101186639768027",
        "Enabled": false,
        "Rate": 0,
        "Lifetime": [
          0.2,
          0.4
        ],
        "Speed": [
          3,
          7
        ],
        "Drag": 5,
        "SpreadAngle": [
          65,
          65
        ],
        "EmissionDirection": "Top",
        "Acceleration": [
          0,
          -9,
          0
        ],
        "Rotation": [
          0,
          360
        ],
        "RotSpeed": [
          -40,
          40
        ],
        "Color": [
          0.14,
          0.13,
          0.12
        ],
        "LightEmission": 0,
        "LightInfluence": 1,
        "Size": [
          {
            "time": 0,
            "value": 0.3
          },
          {
            "time": 1,
            "value": 0.04
          }
        ],
        "Transparency": [
          {
            "time": 0,
            "value": 0.15
          },
          {
            "time": 0.7,
            "value": 0.55
          },
          {
            "time": 1,
            "value": 1
          }
        ]
      },
      "attributes": {
        "EmitCount": 6,
        "EmitDelay": 0
      }
    }
  ],
  "AXZFSurfaceDust": [
    {
      "op": "create",
      "className": "Attachment",
      "id": "contact",
      "name": "Contact",
      "parent": "$part"
    },
    {
      "op": "create",
      "className": "ParticleEmitter",
      "name": "SmokeBody",
      "parent": "$contact",
      "properties": {
        "Texture": "rbxassetid://123244819470159",
        "Enabled": false,
        "Rate": 0,
        "Lifetime": [
          0.5,
          0.8
        ],
        "Speed": [
          1.5,
          4
        ],
        "Drag": 5,
        "SpreadAngle": [
          65,
          65
        ],
        "EmissionDirection": "Top",
        "Acceleration": [
          0,
          2,
          0
        ],
        "Rotation": [
          0,
          360
        ],
        "RotSpeed": [
          -40,
          40
        ],
        "Color": [
          0.56,
          0.48,
          0.37
        ],
        "LightEmission": 0,
        "LightInfluence": 1,
        "Size": [
          {
            "time": 0,
            "value": 0.7
          },
          {
            "time": 0.3,
            "value": 2.2
          },
          {
            "time": 1,
            "value": 3.5
          }
        ],
        "Transparency": [
          {
            "time": 0,
            "value": 0.35
          },
          {
            "time": 0.4,
            "value": 0.6
          },
          {
            "time": 1,
            "value": 1
          }
        ]
      },
      "attributes": {
        "EmitCount": 4,
        "EmitDelay": 0
      }
    },
    {
      "op": "create",
      "className": "ParticleEmitter",
      "name": "SecondaryBillow",
      "parent": "$contact",
      "properties": {
        "Texture": "rbxassetid://123244819470159",
        "Enabled": false,
        "Rate": 0,
        "Lifetime": [
          0.7,
          1.05
        ],
        "Speed": [
          1,
          2.5
        ],
        "Drag": 5,
        "SpreadAngle": [
          65,
          65
        ],
        "EmissionDirection": "Top",
        "Acceleration": [
          0,
          1.5,
          0
        ],
        "Rotation": [
          0,
          360
        ],
        "RotSpeed": [
          -40,
          40
        ],
        "Color": [
          0.55,
          0.46,
          0.35
        ],
        "LightEmission": 0,
        "LightInfluence": 1,
        "Size": [
          {
            "time": 0,
            "value": 0.9
          },
          {
            "time": 0.4,
            "value": 2.8
          },
          {
            "time": 1,
            "value": 4
          }
        ],
        "Transparency": [
          {
            "time": 0,
            "value": 0.65
          },
          {
            "time": 0.5,
            "value": 0.8
          },
          {
            "time": 1,
            "value": 1
          }
        ]
      },
      "attributes": {
        "EmitCount": 2,
        "EmitDelay": 0.06
      }
    },
    {
      "op": "create",
      "className": "ParticleEmitter",
      "name": "RoadGrit",
      "parent": "$contact",
      "properties": {
        "Texture": "rbxassetid://101186639768027",
        "Enabled": false,
        "Rate": 0,
        "Lifetime": [
          0.2,
          0.4
        ],
        "Speed": [
          3,
          7
        ],
        "Drag": 5,
        "SpreadAngle": [
          65,
          65
        ],
        "EmissionDirection": "Top",
        "Acceleration": [
          0,
          -9,
          0
        ],
        "Rotation": [
          0,
          360
        ],
        "RotSpeed": [
          -40,
          40
        ],
        "Color": [
          0.14,
          0.13,
          0.12
        ],
        "LightEmission": 0,
        "LightInfluence": 1,
        "Size": [
          {
            "time": 0,
            "value": 0.3
          },
          {
            "time": 1,
            "value": 0.04
          }
        ],
        "Transparency": [
          {
            "time": 0,
            "value": 0.15
          },
          {
            "time": 0.7,
            "value": 0.55
          },
          {
            "time": 1,
            "value": 1
          }
        ]
      },
      "attributes": {
        "EmitCount": 6,
        "EmitDelay": 0
      }
    }
  ]
}
]==]
