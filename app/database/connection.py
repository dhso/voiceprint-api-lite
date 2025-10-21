import sqlite3
from typing import Optional
from contextlib import contextmanager
from pathlib import Path
import threading
from ..core.config import settings
from ..core.logger import get_logger

logger = get_logger(__name__)


class DatabaseConnection:
    """SQLite数据库连接管理类"""

    def __init__(self):
        self._connection: Optional[sqlite3.Connection] = None
        self._lock = threading.Lock()  # SQLite需要线程锁来保证线程安全
        self._db_path = self._get_db_path()
        self._init_database()
        self._connect()

    def _get_db_path(self) -> str:
        """获取数据库文件路径"""
        # 从配置中获取数据库路径，默认为 data/voiceprint.db
        db_config = settings.sqlite if hasattr(settings, 'sqlite') else {}
        db_path = db_config.get('database', 'data/voiceprint.db')

        # 确保目录存在
        db_dir = Path(db_path).parent
        db_dir.mkdir(parents=True, exist_ok=True)

        return str(Path(db_path).resolve())

    def _init_database(self) -> None:
        """初始化数据库表结构"""
        try:
            # 临时连接用于创建表
            conn = sqlite3.connect(self._db_path)
            cursor = conn.cursor()

            # 创建声纹表
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS voiceprints (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    speaker_id TEXT NOT NULL UNIQUE,
                    feature_vector BLOB NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)

            # 创建索引
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_speaker_id
                ON voiceprints(speaker_id)
            """)

            # 创建触发器来自动更新 updated_at
            cursor.execute("""
                CREATE TRIGGER IF NOT EXISTS update_timestamp
                AFTER UPDATE ON voiceprints
                BEGIN
                    UPDATE voiceprints SET updated_at = CURRENT_TIMESTAMP
                    WHERE id = NEW.id;
                END
            """)

            conn.commit()
            conn.close()
            logger.success(f"数据库初始化成功: {self._db_path}")
        except Exception as e:
            logger.fail(f"数据库初始化失败: {e}")
            raise

    def _connect(self) -> None:
        """建立数据库连接"""
        try:
            # SQLite连接配置
            self._connection = sqlite3.connect(
                self._db_path,
                check_same_thread=False,  # 允许多线程访问
                timeout=30.0,  # 连接超时时间
                isolation_level=None  # 自动提交模式
            )

            # 启用外键约束（如果需要）
            self._connection.execute("PRAGMA foreign_keys = ON")

            # 优化SQLite性能
            self._connection.execute("PRAGMA journal_mode = WAL")  # 使用WAL模式提高并发
            self._connection.execute("PRAGMA synchronous = NORMAL")  # 平衡性能和安全性
            self._connection.execute("PRAGMA temp_store = MEMORY")  # 临时表存储在内存中
            self._connection.execute("PRAGMA mmap_size = 30000000000")  # 使用内存映射

            logger.success(f"SQLite数据库连接成功: {self._db_path}")
        except Exception as e:
            logger.fail(f"SQLite数据库连接失败: {e}")
            raise

    @contextmanager
    def get_cursor(self):
        """获取数据库游标的上下文管理器（线程安全）"""
        with self._lock:  # 使用线程锁确保线程安全
            if not self._connection:
                self._connect()

            cursor = None
            try:
                cursor = self._connection.cursor()
                yield cursor
                self._connection.commit()  # 显式提交
            except Exception as e:
                logger.fail(f"数据库操作失败: {e}")
                if self._connection:
                    self._connection.rollback()
                raise
            finally:
                if cursor:
                    cursor.close()

    def close(self) -> None:
        """关闭数据库连接"""
        if self._connection:
            self._connection.close()
            self._connection = None
            logger.info("SQLite数据库连接已关闭")

    def __del__(self):
        """析构函数，确保连接被关闭"""
        try:
            self.close()
        except:
            pass  # 忽略析构时的异常


# 全局数据库连接实例
db_connection = DatabaseConnection()
