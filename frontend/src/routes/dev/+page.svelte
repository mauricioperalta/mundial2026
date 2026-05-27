<script lang="ts">
	import { pb } from '$lib/pb';
	import { serverClock } from '$lib/serverclock.svelte';
	import { api, type LeagueSummary } from '$lib/api';

	let when = $state('');
	let busy = $state(false);
	let msg = $state('');

	let botCount = $state(3);
	let botLeague = $state('');
	let leagues = $state<LeagueSummary[]>([]);

	$effect(() => {
		if (serverClock.dev)
			api
				.myLeagues()
				.then((r) => (leagues = r.leagues))
				.catch(() => {});
	});

	async function genBots() {
		busy = true;
		msg = '';
		try {
			await pb.send('/api/dev/bots', {
				method: 'POST',
				body: { count: botCount, leagueId: botLeague }
			});
			location.reload();
		} catch (e: unknown) {
			msg = (e as { message?: string })?.message ?? 'Error al generar bots.';
			busy = false;
		}
	}

	$effect(() => {
		serverClock.refresh();
	});

	// Inicializar el campo con la hora simulada actual (o la real si no hay simulación).
	$effect(() => {
		if (!when) {
			const base = serverClock.simTime
				? new Date(serverClock.simTime)
				: new Date(serverClock.now());
			when = base.toISOString().slice(0, 16);
		}
	});

	const presets: { label: string; iso: string }[] = [
		{ label: 'Antes del torneo (Bloqueo del Pronóstico)', iso: '2026-06-10T12:00:00Z' },
		{ label: 'Mitad de la Fase de Grupos', iso: '2026-06-19T18:00:00Z' },
		{ label: 'Fin de la Fase de Grupos / Cruces definidos', iso: '2026-06-28T00:00:00Z' },
		{ label: 'Durante los Cuartos de Final', iso: '2026-07-10T19:45:00Z' },
		{ label: 'Día de la Gran Final (Post-partido)', iso: '2026-07-19T23:00:00Z' }
	];

	async function jump(iso: string) {
		busy = true;
		msg = '';
		try {
			await pb.send('/api/dev/clock', {
				method: 'POST',
				body: { fakeNow: iso }
			});
			location.reload();
		} catch (e: unknown) {
			msg = (e as { message?: string })?.message ?? 'Error al cambiar la hora.';
			busy = false;
		}
	}

	async function reset() {
		if (!confirm('¿Estás seguro de que querés borrar todos los resultados cargados y los bots?')) return;
		busy = true;
		msg = '';
		try {
			await pb.send('/api/dev/reset', { method: 'POST' });
			location.reload();
		} catch (e: unknown) {
			msg = (e as { message?: string })?.message ?? 'Error al reiniciar.';
			busy = false;
		}
	}
</script>

<h1>Entorno de Desarrollo</h1>

{#if !serverClock.dev}
	<p class="error">
		El arnés de desarrollo no está activo. Iniciá el backend con la variable de entorno <code>WMP_DEV=1</code> para desbloquear este panel.
	</p>
{:else}
	<section class="card state">
		<p class="small uppercase muted">Estado del sistema</p>
		<span>Modo Desarrollador: <b>ACTIVO</b></span>
		<span>Hora real del sistema: <b>{new Date().toLocaleTimeString()}</b></span>
		<span>Hora virtual del servidor: <b>{serverClock.formatted}</b></span>
		{#if serverClock.isSimulated}
			<span class="warn-pill">El reloj está simulado (Viaje en el tiempo activo)</span>
		{/if}
	</section>

	<section class="card">
		<h3>Viaje en el Tiempo (Reloj Virtual)</h3>
		<p class="muted small">
			Modificá la hora del servidor para comprobar el bloqueo de pronósticos, cierres de partidos y cálculos de puntuaciones en vivo a lo largo del torneo.
		</p>

		<div class="field">
			<label for="dt">Establecer fecha y hora local</label>
			<input id="dt" class="input" type="datetime-local" bind:value={when} />
		</div>
		<button
			class="btn"
			disabled={busy || !when}
			onclick={() => jump(new Date(when).toISOString())}
		>
			{busy ? 'Viajando en el tiempo…' : 'Actualizar reloj'}
		</button>

		<div class="presets">
			<span class="small uppercase muted">Saltos rápidos</span>
			{#each presets as p}
				<button
					type="button"
					class="p-btn"
					disabled={busy}
					onclick={() => jump(p.iso)}
				>
					{p.label}
				</button>
			{/each}
		</div>
	</section>

	<section class="card">
		<h3>Generador de Jugadores (Bots)</h3>
		<p class="muted small">
			Crea jugadores artificiales de forma automática. Cada bot completará un Pronóstico Inicial aleatorio y cargará predicciones para todos los partidos individuales del torneo.
		</p>
		<div class="field">
			<label for="bc">Cantidad de bots a crear</label>
			<input
				id="bc"
				class="input"
				type="number"
				min="1"
				max="20"
				bind:value={botCount}
			/>
		</div>
		<div class="field">
			<label for="bl">Liga de destino</label>
			<select id="bl" class="input" bind:value={botLeague}>
				<option value="">En todas mis ligas</option>
				{#each leagues as l (l.id)}
					<option value={l.id}>{l.name}</option>
				{/each}
			</select>
		</div>
		<button class="btn" disabled={busy} onclick={genBots}>
			{busy ? 'Generando…' : `Generar ${botCount} bot${botCount === 1 ? '' : 's'}`}
		</button>
	</section>

	<section class="card">
		<h3>Reiniciar Entorno</h3>
		<p class="muted small">
			Limpia por completo todos los resultados cargados en los partidos y elimina los bots creados, restableciendo el reloj virtual al tiempo real actual.
		</p>
		<button class="btn secondary" disabled={busy} onclick={reset}>
			{busy ? 'Reiniciando…' : 'Reiniciar todo a cero'}
		</button>
	</section>

	{#if msg}<p class="error">{msg}</p>{/if}
{/if}

<style>
	/* El CSS se mantiene intacto */
	h1 {
		margin: 0.1rem 0 1rem;
	}
	.small {
		font-size: 0.85rem;
	}
	.state {
		display: flex;
		flex-direction: column;
		gap: 0.3rem;
	}
	.state b {
		font-size: 1rem;
	}
	.warn-pill {
		display: inline-block;
		margin-top: 0.4rem;
		background: var(--warning-subtle, #fef08a);
		color: var(--warning-text, #854d0e);
		border: 1px solid var(--warning-border, #fef08a);
		padding: 4px 10px;
		border-radius: var(--radius-sm);
		font-size: 0.8rem;
		font-weight: 700;
		width: fit-content;
	}
	h3 {
		margin: 0 0 0.5rem;
		font-family: var(--font-display);
		text-transform: uppercase;
		font-size: 1rem;
	}
	.card {
		background: var(--surface);
		border: 1px solid var(--border);
		border-radius: var(--radius);
		padding: 1.5rem;
		margin-top: 1.25rem;
		display: flex;
		flex-direction: column;
		box-shadow: var(--shadow-sm);
	}
	.field {
		display: flex;
		flex-direction: column;
		gap: 0.35rem;
		margin-bottom: 1rem;
	}
	label {
		font-size: 0.75rem;
		font-weight: 700;
		text-transform: uppercase;
		letter-spacing: 0.05em;
		color: var(--muted);
	}
	.input {
		background: var(--surface-2);
		border: 1px solid var(--border);
		border-radius: var(--radius-sm);
		padding: 0.55rem 0.75rem;
		color: var(--text);
		font-size: 0.95rem;
		width: 100%;
		max-width: 320px;
		transition: border-color 0.15s ease;
	}
	.input:focus {
		outline: none;
		border-color: var(--accent);
	}
	.btn {
		max-width: 320px;
	}
	.presets {
		margin-top: 1.5rem;
		display: flex;
		flex-direction: column;
		gap: 0.4rem;
		border-top: 1px solid var(--border);
		padding-top: 1rem;
	}
	.p-btn {
		background: var(--surface-2);
		border: 1px solid var(--border);
		border-radius: var(--radius-sm);
		padding: 0.5rem 0.75rem;
		color: var(--text);
		text-align: left;
		font-size: 0.85rem;
		font-weight: 600;
		cursor: pointer;
		max-width: 320px;
	}
	.p-btn:hover {
		border-color: var(--accent);
		background: var(--surface);
	}
	.error {
		background: var(--danger-subtle, #fde8e8);
		color: var(--danger, #e02424);
		border: 1px solid var(--danger-border, #f8b4b4);
		padding: 0.65rem 0.85rem;
		border-radius: var(--radius-sm);
		font-size: 0.85rem;
		font-weight: 500;
		margin-top: 1rem;
	}
	code {
		font-family: monospace;
		background: rgba(0,0,0,0.06);
		padding: 2px 4px;
		border-radius: 4px;
	}
</style>
