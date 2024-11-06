SELECT COUNT(*) cnt
FROM {{ ref('recipes') }}
