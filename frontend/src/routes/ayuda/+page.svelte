<script lang="ts">
	let open = $state<number | null>(null);

	const faqs = [
		{
			q: '¿Cómo se juega?',
			a: `<p>¡Bienvenido/a al desafío de predicciones de la empresa! Para participar y sumar puntos en AudiMundial, debés completar dos secciones distintas con mecánicas y reglas de cierre diferentes.</p>
			<p><b>1. Pronóstico: El desafío partido a partido</b><br/>El Pronóstico se refiere a las apuestas individuales que realizás para cada uno de los 104 encuentros del Mundial.</p>
			<ul>
				<li><b>Qué elegís:</b> El marcador exacto de cada encuentro (ej. España 2 - 0 Japón). En fase de eliminación, el sistema te permite elegir quién avanza de ronda (considerando tiempo extra y penales).</li>
				<li><b>Puntuación:</b> Sumás puntos por acertar al ganador, el marcador exacto, la diferencia de goles y la cantidad total de tantos.</li>
				<li><b>Tiempo Límite:</b> Cada partido es independiente. Podés cargar o editar el marcador hasta el pitazo inicial (Kick-off). Una vez que el partido comienza, el sistema bloquea la edición.</li>
				<li><b>Forma de Guardado:</b> Los resultados se guardan automáticamente. Verás un indicador visual confirmando el registro.</li>
			</ul>
			<p><b>2. Predicción: Tu visión del torneo (Simulador)</b><br/>La Predicción es una configuración única y global de cómo creés que terminará el cuadro general del Mundial.</p>
			<ul>
				<li><b>Cómo se completa:</b> Solo definís las posiciones de la Fase de Grupos y los mejores terceros (solo podés elegir 8). A partir de ahí, el sistema arma automáticamente los cruces de la Ronda de 32. Luego debés seleccionar quién gana cada encuentro hasta la Final.</li>
				<li><b>Efecto Cascada:</b> Al elegir al ganador de una llave, el sistema lo posiciona automáticamente en la siguiente etapa.</li>
				<li><b>Tiempo Límite:</b> Hasta el minuto exacto en que comience el partido inaugural del Mundial (11 de junio de 2026). Después se bloquea definitivamente.</li>
				<li><b>⚠ Advertencia:</b> Si modificás una posición de grupos después de haber completado el cuadro, el sistema recalculará todos los cruces posteriores.</li>
			</ul>
			<p><b>Nota final:</b> Asegurate de tener conexión estable a internet al realizar tus elecciones. ¡Mucha suerte!</p>`
		},
		{
			q: '¿Cómo se calculan los puntos?',
			a: `<p><b>Por partido (Pronóstico):</b></p>
			<ul>
				<li><b>Resultado correcto</b> (ganador o empate en grupos): puntos base</li>
				<li><b>Resultado exacto:</b> puntos adicionales</li>
				<li><b>Total de goles correcto:</b> puntos adicionales</li>
				<li><b>Diferencia de goles correcta:</b> puntos adicionales</li>
			</ul>
			<p><b>Por Predicción Inicial:</b></p>
			<ul>
				<li>Cada equipo en su posición correcta de grupo</li>
				<li>Bonus por grupo entero ordenado perfectamente</li>
				<li>Por cada equipo que clasificó correctamente</li>
				<li>Puntos extra por cada ronda eliminatoria alcanzada</li>
			</ul>
			<p>Los desempates se resuelven por: más resultados exactos, más ganadores correctos, menor error de diferencia de goles, menos pronósticos enviados y última edición más temprana.</p>`
		},
		{
			q: '¿Cómo cargo un pronóstico?',
			a: `<p>Andá a <b>Pronósticos</b> en el menú. Encontrarás todos los partidos del Mundial. Hacé clic en el partido que querés pronosticar, ingresá el marcador y presioná <b>GUARDAR PRONÓSTICO</b>. Podés modificarlo hasta el pitazo inicial de ese partido.</p>`
		},
		{
			q: '¿Hasta cuándo puedo modificar mis pronósticos?',
			a: `<p>Cada partido tiene su propio límite. Podés modificar tu pronóstico hasta el momento exacto del pitazo inicial (Kick-off) de ese encuentro. Una vez que el partido comienza, el sistema bloquea la edición automáticamente.</p>`
		},
		{
			q: '¿Qué es la Predicción Inicial y hasta cuándo puedo completarla?',
			a: `<p>La Predicción Inicial es tu pronóstico global del torneo: cómo terminan los grupos, qué equipos clasifican como mejores terceros y el recorrido de cada equipo en la fase eliminatoria. Podés completarla hasta el minuto exacto en que comience el primer partido del Mundial (<b>11 de junio de 2026</b>). Después se bloquea definitivamente.</p>`
		},
		{
			q: '¿Quiénes pueden ganar premios?',
			a: `<p>Son elegibles para premios todos los colaboradores y contratados de AudiRed que obtengan las máximas puntuaciones al finalizar el torneo, siempre que mantengan una conducta acorde a los términos y condiciones de uso. Los premios serán comunicados por la organización con anticipación al inicio del torneo.</p>`
		},
		{
			q: '¿Puedo participar desde mi celular?',
			a: `<p>Sí. AudiMundial está optimizado para dispositivos móviles. Podés instalarlo como aplicación en tu celular — cuando entrés al sitio desde el navegador, te aparecerá la opción de instalarlo en tu pantalla de inicio. Funciona tanto dentro como fuera de la red corporativa.</p>`
		},
		{
			q: '¿Puedo tener más de una cuenta?',
			a: `<p>Sí, podés registrarte con más de una cuenta para seguir diferentes estrategias. Cada cuenta compite de manera independiente. Sin embargo, la organización no se responsabiliza por confusiones o pérdidas de acceso derivadas del uso de múltiples cuentas.</p>`
		},
		{
			q: '¿Cómo veo las posiciones?',
			a: `<p>Andá a <b>Ligas</b> en el menú y seleccioná la liga <b>Mundial 2026</b>. Ahí encontrarás la tabla de posiciones con todos los participantes ordenados por puntos. Podés filtrar por puntos totales, pronósticos o predicción.</p>`
		},
		{
			q: '¿Qué pasa si hay un error en los resultados?',
			a: `<p>Los resultados se obtienen de fuentes externas y se actualizan automáticamente cada 30 minutos. Si notás un error contactá a <a href="mailto:soporte@audired.com.ar">soporte@audired.com.ar</a> indicando el partido y el resultado correcto.</p>`
		},
		{
			q: '¿A quién contacto si tengo un problema?',
			a: `<p>Para cualquier consulta o problema técnico escribí a <a href="mailto:soporte@audired.com.ar">soporte@audired.com.ar</a>. Intentá incluir una descripción del problema y, si es posible, una captura de pantalla.</p>`
		}
	];
</script>

<p class="kicker">Centro de ayuda</p>
<h1>Ayuda</h1>
<p class="muted desc">Preguntas frecuentes sobre AudiMundial 2026.</p>

<div class="faqs">
	{#each faqs as faq, i (faq.q)}
		<details class="card faq" ontoggle={(e) => { if ((e.target as HTMLDetailsElement).open) open = i; else if (open === i) open = null; }}>
			<summary>{faq.q}</summary>
			<div class="body">{@html faq.a}</div>
		</details>
	{/each}
</div>

<section class="card contact">
	<h3>¿No encontrás lo que buscás?</h3>
	<p class="muted">Escribinos y te respondemos a la brevedad.</p>
	<p class="muted">📧 <b>soporte@audired.com.ar</b></p>
</section>

<style>
	h1 { margin: 0.5rem 0 0.25rem; }
	.desc { margin: 0 0 1.5rem; font-size: 0.95rem; }
	.faqs { display: flex; flex-direction: column; gap: 0.5rem; }
	.faq summary {
		cursor: pointer;
		font-weight: 700;
		letter-spacing: 0.04em;
		text-transform: uppercase;
		font-size: 0.85rem;
		color: var(--accent);
		list-style: none;
	}
	.faq summary::before { content: '▶ '; font-size: 0.75rem; }
	.faq[open] summary::before { content: '▼ '; }
	.body { font-size: 0.85rem; color: var(--muted); line-height: 1.6; }
	.body p { margin: 0 0 0.5rem; }
	.body ul { padding-left: 1.2rem; margin: 0.25rem 0 0.5rem; }
	.body li { padding: 0.2rem 0; }
	.body b { color: var(--text); }
	.body a { color: var(--accent); }
	.contact { margin-top: 1rem; }
	.contact h3 { margin: 0 0 0.4rem; }
	.contact .btn { margin-top: 0.75rem; display: inline-block; }
</style>
