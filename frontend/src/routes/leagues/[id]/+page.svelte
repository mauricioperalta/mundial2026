<script lang="ts">
	import { page } from '$app/stores';
	import { api, type LeaderboardRow } from '$lib/api';
	import { auth } from '$lib/auth.svelte';
	import {
		Eye,
		EyeOff,
		Copy,
		Share2,
		ChevronDown,
		Telescope
	} from '@lucide/svelte';

	interface Cfg {
		match: {
			tendency: number;
			exact: number;
			totalGoals: number;
			goalDiff: number;
		};
		forecast: {
			groupPosition: number;
			perfectGroupBonus: number;
			advance: number;
			round: Record<string, number>;
		};
		tiebreakers: string[];
	}
	let cfg = $state<Cfg | null>(null);

	const tbLabel: Record<string, string> = {
		points: 'Puntos totales',
		exactScores: 'Más resultados exactos',
		correctWinners: 'Más ganadores correctos',
		goalDiffDeviation: 'Menor error de diferencia de goles vs. resultados',
		fewestTips: 'Menos pronósticos enviados',
		earliestEdit: 'Última edición más temprana (enviado primero)'
	};
	const roundLabel: Record<string, string> = {
		R32: 'Ronda de 32',
		R16: 'Octavos de final',
		QF: 'Cuartos de final',
		SF: 'Semifinales',
		FINAL: 'Final',
		CHAMPION: 'Campeón'
	};

	let revealed = $state(false);
	let openRow = $state<string | null>(null);

	let id = $derived($page.params.id ?? '');
	let league = $state<{ id: string; name: string } | null>(null);
	let rows = $state<LeaderboardRow[]>([]);
	let invite = $state('');
	let loaded = $state(false);
	let error = $state('');
	let tab = $state<'total' | 'tipsPoints' | 'forecastPoints'>('total');

	$effect(() => {
		const lid = id;
		loaded = false;
		cfg = null;
		Promise.all([api.leaderboard(lid), api.myLeagues()])
			.then(([lb, mine]) => {
				league = lb.league;
				rows = lb.rows;
				cfg = (lb.scoring as Cfg | undefined) ?? null;
				invite = mine.leagues.find((l) => l.id === lid)?.inviteCode ?? '';
			})
			.catch(() => (error = 'No se pudo cargar esta liga.'))
			.finally(() => (loaded = true));
	});

	let sorted = $derived(
		[...rows].sort((a, b) => b[tab] - a[tab])
	);
	let fcView = $derived(tab === 'forecastPoints');

	function copyInvite() {
		navigator.clipboard?.writeText(invite);
	}

	let linkCopied = $state(false);
	let copyTimer: ReturnType<typeof setTimeout>;
	function shareInvite() {
		const url = `${window.location.origin}/join/${invite}`;
		navigator.clipboard?.writeText(url);
		linkCopied = true;
		clearTimeout(copyTimer);
		copyTimer = setTimeout(() => (linkCopied = false), 1800);
	}
</script>

<a href="/leagues" class="muted back">← Ligas</a>

{#if error}
	<p class="error">{error}</p>
{:else if !loaded}
	<p class="muted">Cargando…</p>
{:else if league}
	<p class="kicker">Liga</p>
	<h1>{league.name}</h1>

	{#if invite && invite !== 'GLOBAL'}
		<section class="card invite">
			<div class="irow">
				<div class="ic">
					<div class="muted small">Código de invitación</div>
					<div class="code" class:masked={!revealed}>
						{revealed ? invite : '•'.repeat(invite.length || 6)}
					</div>
				</div>
				<div class="spacer"></div>
				<button
					class="btn secondary eye"
					aria-label={revealed ? 'Ocultar código' : 'Mostrar código'}
					onclick={() => (revealed = !revealed)}
				>
					{#if revealed}<EyeOff size={18} />{:else}<Eye size={18} />{/if}
				</button>
				<button class="btn secondary copy" onclick={copyInvite}>
					<Copy size={16} /> Copiar
				</button>
			</div>
			<button class="btn share" onclick={shareInvite}>
				<Share2 size={16} />
				{linkCopied ? '¡Enlace copiado!' : 'Compartir enlace de invitación'}
			</button>
		</section>
	{/if}

	<section class="card">
		<div class="tabs">
			<button class:active={tab === 'total'} onclick={() => (tab = 'total')}>General</button>
			<button class:active={tab === 'tipsPoints'} onclick={() => (tab = 'tipsPoints')}>Pronósticos</button>
			<button class:active={tab === 'forecastPoints'} onclick={() => (tab = 'forecastPoints')}>Predicción</button>
		</div>

		<table class="lb">
			<thead>
				<tr>
					<th>#</th>
					<th>Jugador</th>
					{#if fcView}
						<th class="num ext" title="Posiciones de grupo correctas">Grp</th>
						<th class="num ext" title="Clasificados correctos (fase de grupos)">Cla</th>
						<th class="num ext" title="Equipos que llegaron a Ronda de 32">R32</th>
						<th class="num ext" title="…Octavos de final">R16</th>
						<th class="num ext" title="…Cuartos de final">QF</th>
						<th class="num ext" title="…Semifinales">SF</th>
						<th class="num ext" title="…Final">F</th>
						<th class="num ext" title="Campeón pronosticado correctamente">Cam</th>
					{:else}
						<th class="num ext" title="Partidos pronosticados">Pred</th>
						<th class="num ext" title="Puntos de predicción">Pred</th>
						<th class="num ext" title="Resultados exactos (desempate 1)">Exacto</th>
						<th class="num ext" title="Ganadores correctos (desempate 2)">Gan</th>
						<th class="num ext" title="Error de diferencia de goles (desempate 3, menor es mejor)">DG&Delta;</th>
					{/if}
					<th class="num pts">Pts</th>
				</tr>
			</thead>
			<tbody>
				{#each sorted as r, i (r.userId)}
					{@const f = r.forecast ?? {}}
					<tr
						class:lead={r.userId === auth.user?.id}
						class="main"
						class:open={openRow === r.userId}
						onclick={() =>
							(openRow = openRow === r.userId ? null : r.userId)}
					>
						<td class="rank">{i + 1}</td>
						<td class="player">
							<div class="pwrap">
								<span class="pname">{r.name}</span>
								<a
									class="fclink"
									href={`/forecast/${r.userId}`}
									title="Ver predicción de {r.name}"
									onclick={(e) => e.stopPropagation()}
								>
									<Telescope size={15} />
								</a>
								<ChevronDown size={14} class="rx" />
							</div>
						</td>
						{#if fcView}
							<td class="num ext digits">{f.groups ?? 0}</td>
							<td class="num ext digits">{f.advance ?? 0}</td>
							<td class="num ext digits">{f.R32 ?? 0}</td>
							<td class="num ext digits">{f.R16 ?? 0}</td>
							<td class="num ext digits">{f.QF ?? 0}</td>
							<td class="num ext digits">{f.SF ?? 0}</td>
							<td class="num ext digits">{f.FINAL ?? 0}</td>
							<td class="num ext digits">{f.champion ? '✓' : '–'}</td>
						{:else}
							<td class="num ext digits">{r.predicted}</td>
							<td class="num ext digits">{r.forecastPoints}</td>
							<td class="num ext digits">{r.exactScores}</td>
							<td class="num ext digits">{r.correctWinners}</td>
							<td class="num ext digits">{r.gdDeviation}</td>
						{/if}
						<td class="num pts digits">{r[tab]}</td>
					</tr>
					{#if openRow === r.userId}
						<tr class="detail">
							<td colspan="12">
								{#if fcView}
									<div class="stats">
										<span><i>Posiciones de grupo correctas</i><b>{f.groups ?? 0}</b></span>
										<span><i>Clasificados correctos</i><b>{f.advance ?? 0}</b></span>
										<span><i>Llegó a Ronda de 32</i><b>{f.R32 ?? 0}</b></span>
										<span><i>Llegó a Octavos de final</i><b>{f.R16 ?? 0}</b></span>
										<span><i>Llegó a Cuartos de final</i><b>{f.QF ?? 0}</b></span>
										<span><i>Llegó a Semifinales</i><b>{f.SF ?? 0}</b></span>
										<span><i>Llegó a la Final</i><b>{f.FINAL ?? 0}</b></span>
										<span><i>Campeón correcto</i><b>{f.champion ? 'Sí' : 'No'}</b></span>
									</div>
								{:else}
									<div class="stats">
										<span><i>Partidos pronosticados</i><b>{r.predicted}</b></span>
										<span><i>Puntos de pronósticos</i><b>{r.tipsPoints}</b></span>
										<span><i>Puntos de predicción</i><b>{r.forecastPoints}</b></span>
										<span><i>Resultados exactos</i><b>{r.exactScores}</b></span>
										<span><i>Ganadores correctos</i><b>{r.correctWinners}</b></span>
										<span><i>Error de diferencia de goles</i><b>{r.gdDeviation}</b></span>
									</div>
								{/if}
							</td>
						</tr>
					{/if}
				{/each}
			</tbody>
		</table>
		<p class="muted small note">
			Los puntos se actualizan automáticamente a medida que llegan los resultados.
		</p>
	</section>

	{#if cfg}
		<details class="card legend">
			<summary>¿Cómo se calculan los puntos?</summary>

			<h4>Por partido (tu Pronóstico) — máx {cfg.match.tendency +
					cfg.match.exact +
					cfg.match.totalGoals +
					cfg.match.goalDiff} pt</h4>
			<ul class="leg">
				<li>
					<span>Resultado correcto — grupos: 1 / X / 2; eliminatorias: el equipo
						que clasifica</span><b>{cfg.match.tendency} pt</b>
				</li>
				<li><span>Resultado exacto</span><b>+{cfg.match.exact} pt</b></li>
				<li><span>Total de goles correcto</span><b>+{cfg.match.totalGoals} pt</b></li>
				<li><span>Diferencia de goles correcta</span><b>+{cfg.match.goalDiff} pt</b></li>
			</ul>
			<p class="muted small">
				Los partidos eliminatorios no pueden terminar en empate — el punto de resultado
				es para el equipo que clasifica. Si un partido eliminatorio se define en tiempo
				extra, los puntos de resultado usan el marcador tras el alargue.
			</p>

			<h4>Predicción Inicial del Torneo</h4>
			<ul class="leg">
				<li><span>Cada equipo en su posición final correcta de grupo</span><b>{cfg.forecast.groupPosition} pt</b></li>
				<li><span>Grupo entero ordenado perfectamente (bonus)</span><b>+{cfg.forecast.perfectGroupBonus} pt</b></li>
				<li>
					<span>Cada equipo que predijiste que iba a clasificar (top 2 del grupo, o
						un tercero elegido) que efectivamente clasificó</span
					><b>{cfg.forecast.advance} pt</b>
				</li>
			</ul>
			<p class="muted small">
				Llegar a una ronda eliminatoria (por equipo pronosticado correctamente):
			</p>
			<ul class="leg">
				{#each Object.entries(roundLabel) as [k, lbl] (k)}
					{#if cfg.forecast.round[k] != null}
						<li><span>{lbl}</span><b>{cfg.forecast.round[k]} pt</b></li>
					{/if}
				{/each}
			</ul>

			<h4>Desempates (en orden)</h4>
			<ol class="tiebreak">
				{#each cfg.tiebreakers as t (t)}
					<li>{tbLabel[t] ?? t}</li>
				{/each}
			</ol>
		</details>
	{/if}
{/if}

<style>
	.back {
		display: inline-block;
		margin: 0.5rem 0 0.75rem;
	}
	h1 {
		margin: 0 0 1rem;
	}
	.irow {
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}
	.share {
		margin-top: 0.85rem;
	}
	.ic {
		min-width: 0;
	}
	.small {
		font-size: 0.8rem;
	}
	.code {
		font-family: var(--font-mono);
		font-weight: 700;
		letter-spacing: 0.2em;
		font-size: 1.3rem;
	}
	.code.masked {
		color: var(--muted);
		letter-spacing: 0.15em;
	}
	.eye {
		width: auto;
		padding: 0.7rem;
	}
	.copy {
		width: auto;
	}
	.tabs {
		display: flex;
		gap: 0.4rem;
		margin-bottom: 0.75rem;
	}
	.tabs button {
		flex: 1;
		padding: 0.5rem;
		background: var(--surface-2);
		border: 1px solid var(--border);
		border-radius: var(--radius-sm);
		color: var(--muted);
		font-weight: 600;
	}
	.tabs button.active {
		color: var(--accent-fg);
		background: var(--accent);
		border-color: var(--accent);
	}
	.lb {
		width: 100%;
		border-collapse: collapse;
	}
	.lb th,
	.lb td {
		text-align: left;
		padding: 0.6rem 0.4rem;
		border-bottom: 1px solid var(--border);
	}
	.lb th {
		color: var(--muted);
		font-size: 0.8rem;
		font-weight: 600;
	}
	.num {
		text-align: right;
	}
	.rank {
		width: 2rem;
		color: var(--muted);
		font-family: var(--font-mono);
	}
	tr.lead td {
		background: color-mix(in srgb, var(--accent) 9%, transparent);
	}
	tr.lead .rank {
		color: var(--accent);
		font-weight: 800;
	}
	.lb th.num,
	.lb td.num {
		text-align: right;
	}

	/* Pts is the focus — set it apart from the stat columns. */
	.lb th.pts,
	.lb td.pts {
		padding-left: 1.15rem;
		border-left: 1px solid var(--border);
		font-size: 1.02rem;
	}
	.lb th.pts {
		font-size: 0.8rem;
	}

	/* Extra tiebreaker columns: desktop only. */
	.ext {
		display: none;
	}
	.player {
		width: 100%;
	}
	.pwrap {
		display: flex;
		align-items: center;
		gap: 0.4rem;
	}
	.pname {
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}
	.fclink {
		display: inline-grid;
		place-items: center;
		color: var(--muted);
		flex: none;
	}
	.fclink:hover {
		color: var(--accent);
	}
	:global(.lb .rx) {
		color: var(--muted);
		transition: transform 0.15s ease;
		margin-left: auto;
	}
	tr.main.open :global(.rx) {
		transform: rotate(180deg);
	}
	tr.main {
		cursor: pointer;
	}
	.detail td {
		padding: 0 0.4rem 0.7rem;
	}
	.stats {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 0.4rem 1rem;
	}
	.stats span {
		display: flex;
		justify-content: space-between;
		gap: 0.6rem;
		padding: 0.35rem 0;
		border-bottom: 1px solid var(--border);
	}
	.stats i {
		color: var(--muted);
		font-style: normal;
		font-size: 0.85rem;
	}
	.stats b {
		font-family: var(--font-mono);
	}

	@media (min-width: 760px) {
		.ext {
			display: table-cell;
		}
		:global(.lb .rx) {
			display: none;
		}
		tr.main {
			cursor: default;
		}
		.detail {
			display: none;
		}
	}
	.note {
		margin: 0.75rem 0 0;
	}
	.legend summary {
		cursor: pointer;
		font-weight: 700;
		letter-spacing: 0.04em;
		text-transform: uppercase;
		font-size: 0.85rem;
		color: var(--accent);
	}
	.legend h4 {
		margin: 1rem 0 0.5rem;
		font-size: 0.95rem;
	}
	.legend .small {
		margin: 0.4rem 0 0;
	}
	ul.leg {
		list-style: none;
		margin: 0;
		padding: 0;
	}
	ul.leg li {
		display: flex;
		align-items: baseline;
		gap: 0.75rem;
		padding: 0.4rem 0;
		border-bottom: 1px solid var(--border);
	}
	ul.leg li span {
		flex: 1;
	}
	ul.leg li b {
		font-family: var(--font-mono);
		color: var(--accent);
		white-space: nowrap;
	}
	ol.tiebreak {
		margin: 0.5rem 0 0;
		padding-left: 1.3rem;
		line-height: 1.8;
	}
	ol.tiebreak li {
		padding-left: 0.3rem;
	}
</style>
