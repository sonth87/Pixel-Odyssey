@abstract
class_name EffectData
extends Resource
## One primitive effect an item, passive or transform can grant
## (docs/01-game-design/04-items-and-powerups.md §3, docs/05-technical/04-data-schemas.md § EffectData).
## A subclass only holds typed design parameters; EffectHost (runner/effects/) is where they actually act.
