from collections import deque
import copy

# Estado inicial y objetivo
estado_inicial = [
    [1, 2, 3],
    [4, 0, 6],
    [7, 5, 8]
]

estado_objetivo = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 0]
]

# Movimientos posibles
MOVIMIENTOS = {
    "arriba": (-1, 0),
    "abajo": (1, 0),
    "izquierda": (0, -1),
    "derecha": (0, 1)
}

def imprimir_estado(estado):
    for fila in estado:
        print(fila)
    print()

def bfs(estado_inicial, estado_objetivo):
    Q = deque()
    visitados = set()
    iteracion = 0

    Q.append((estado_inicial, []))
    visitados.add(str(estado_inicial))

    while Q:
        iteracion += 1
        estado, camino = Q.popleft()

        print(f"\n🔄 Iteración {iteracion}")
        print("Estado actual (expandido):")
        imprimir_estado(estado)
        print("Camino hasta aquí:", camino)

        print("📌 Cola actual:")
        for e, _ in Q:
            imprimir_estado(e)

        print("✅ Visitados:")
        for v in visitados:
            print(v)
        print("------------")

        if estado == estado_objetivo:
            print("🎉 ¡Estado objetivo alcanzado!")
            return camino

        # Buscar la posición del 0
        for i in range(3):
            for j in range(3):
                if estado[i][j] == 0:
                    x, y = i, j
                    break

        for accion, (dx, dy) in MOVIMIENTOS.items():
            nx, ny = x + dx, y + dy
            if 0 <= nx < 3 and 0 <= ny < 3:
                nuevo_estado = copy.deepcopy(estado)
                nuevo_estado[x][y], nuevo_estado[nx][ny] = nuevo_estado[nx][ny], nuevo_estado[x][y]

                estado_str = str(nuevo_estado)
                if estado_str not in visitados:
                    visitados.add(estado_str)
                    Q.append((nuevo_estado, camino + [accion]))

                    print(f"➕ Insertado nuevo estado por '{accion}':")
                    imprimir_estado(nuevo_estado)

    print("❌ No se encontró una solución.")
    return None
solucion = bfs(estado_inicial, estado_objetivo)

if solucion:
    print("\n✅ Solución encontrada:")
    for paso, accion in enumerate(solucion, 1):
        print(f"{paso}. {accion}")
else:
    print("\n❌ No se encontró solución.")
