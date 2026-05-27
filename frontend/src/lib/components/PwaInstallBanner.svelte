<script lang="ts">
	import { pwa } from '$lib/pwa.svelte';
	import { Download, X, Share } from '@lucide/svelte';
</script>

{#if pwa.bannerOpen}
	<div class="banner" role="region" aria-label="Instalar aplicación">
		<div class="inner">
			<Download size={18} class="ico" />
			<div class="msg">
				<strong>Instalar Aplicación</strong>
				<span class="muted small">Inicio más rápido, a pantalla completa y sin barra de navegación.</span>
			</div>
			<button class="btn install" onclick={() => pwa.install()}>Instalar</button>
			<button
				class="x"
				aria-label="Descartar"
				onclick={() => pwa.dismissBanner()}
			>
				<X size={16} />
			</button>
		</div>
	</div>
{/if}

{#if pwa.iosHelpOpen}
	<button
		type="button"
		class="ios-backdrop"
		aria-label="Cerrar"
		onclick={() => pwa.closeIosHelp()}
	></button>
	<div class="ios-sheet" role="dialog" aria-label="Instrucciones de instalación">
		<h3>Añadir AudiMundial a tu pantalla de inicio</h3>
		<ol>
			<li>
				Toca el botón <span class="kbd"><Share size={14} /> Compartir</span> en la barra de herramientas de Safari.
			</li>
			<li>Desplázate hacia abajo y selecciona <strong>Añadir a la pantalla de inicio</strong>.</li>
			<li>Toca <strong>Añadir</strong> en la esquina superior derecha.</li>
		</ol>
		<button class="btn" onclick={() => pwa.closeIosHelp()}>Entendido</button>
	</div>
{/if}

<style>
	.banner {
		background: var(--surface-2);
		border-bottom: 1px solid var(--border);
		padding: 0.75rem 1rem;
	}
	.inner {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		max-width: 1200px;
		margin: 0 auto;
	}
	:global(.inner .ico) {
		color: var(--accent);
		flex: none;
	}
	.msg {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 2px;
	}
	.msg strong {
		font-size: 0.9rem;
	}
	.btn.install {
		padding: 0.45rem 0.85rem;
		font-size: 0.85rem;
		width: auto;
	}
	.x {
		display: inline-grid;
		place-items: center;
		width: 32px;
		height: 32px;
		border-radius: 999px;
		background: transparent;
		color: var(--muted);
		border: 1px solid transparent;
		cursor: pointer;
	}
	.x:hover {
		color: var(--text);
		background: var(--surface-2);
	}
	.ios-backdrop {
		position: fixed;
		inset: 0;
		background: rgba(0, 0, 0, 0.45);
		border: none;
		padding: 0;
		z-index: 60;
		cursor: pointer;
	}
	.ios-sheet {
		position: fixed;
		inset: auto 0.75rem calc(var(--nav-h, 0px) + 0.75rem) 0.75rem;
		z-index: 61;
		background: var(--surface);
		border: 1px solid var(--border);
		border-radius: var(--radius);
		padding: 1rem 1.1rem 1.1rem;
		box-shadow: var(--shadow-pop);
		max-width: 420px;
		margin: 0 auto;
	}
	@media (min-width: 440px) {
		.ios-sheet {
			left: auto;
			right: 0.75rem;
		}
	}
	.ios-sheet h3 {
		margin: 0 0 0.75rem;
		font-size: 1.1rem;
	}
	.ios-sheet ol {
		margin: 0 0 1.25rem;
		padding-left: 1.25rem;
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
		font-size: 0.9rem;
		line-height: 1.4;
	}
	.kbd {
		display: inline-flex;
		align-items: center;
		gap: 4px;
		background: var(--surface-2);
		border: 1px solid var(--border);
		border-radius: 4px;
		padding: 1px 5px;
		font-size: 0.8rem;
	}
</style>
